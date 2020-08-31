function Sim(action)
% High-Field Asymmetric Waveform Ion Mobility Spectrometry simulation software.

global Mx RE IM Wx ModZ Fase CAP CON %Ion{conti}.trajectory.x Ion{conti}.trajectory.y
global  handle_CVstep handle_CVmin handle_CVmax CVstep CVmin CVmax tvect Vin
global handle_Vm handle_Vpp handle_n handle_g handle_L handle_a2 handle_a4 handle_Ko handle_freq handle_DtC
global Vm Vpp n g L a2 a4 Ko freq DtC SpecCV Yo SpecIon Mtit2 lxy flagwf CV DeltayH Deltayl tH tl
global figNumber v_serieIM v_serieLOG Flagret Ion conti Flagsave Mdat2x Mdat2y 
% Manejador del eje
global v_serie v_serie2; %v_serie3 v_serie4 v_serie5;



%Calculos teoricos
%Compensation Voltage
CV=CVmin;
%Contador CV
Cont2=0;
%while for the different CVs
while CV<=CVmax
    Cont2=Cont2+1;
    Delta;
% %Electric field High 
% EH=((Vpp*(1-(DtC/100)))+CV)/g;
% %Electric field low
% El=((Vpp*(DtC/100))-CV)/g;
% 
% %[E/N]High in Td (E/N)/1e-21
% ENH=EH/(n*1e-21);
% %[E/N]Low in Td (E/N)/1e-21
% ENl=El/(n*1e-21);
% 
% %Alpha High
% AlphaH=(a2*(ENH)^2)+(a4*(ENH)^4);
% %Alpha Low
% Alphal=(a2*(ENl)^2)+(a4*(ENl)^4);
% 
% %Ion mobility High
% KH=Ko*(1+AlphaH);
% %Ion mobility Low
% Kl=Ko*(1+Alphal);
% 
% %Position change in Y due to the electric field
% DeltayH= KH*EH*tH;
% Deltayl= Kl*El*tl;
% %if the wave form is not ideal the deltas must be multiplied by a factor:
% if flagwf>0
%     DeltayH= DeltayH*0.76;
%     Deltayl= Deltayl*0.76;
% end

%Calculate ion position

% Create 2 vectors of length 1000000 full with NaN

Ion{conti}.trajectory.x=NaN(1000000,1);
Ion{conti}.trajectory.y=NaN(1000000,1);
%Initial position
Ion{conti}.trajectory.x(1)=0;
Ion{conti}.trajectory.y(1)=Yo;


%Position change in X due to the flow vel

% DeltaxH= Vm*tH;
% Deltaxl= Vm*tl;

cont=1;
%while Ion{conti}.trajectory.x(cont)<L && Ion{conti}.trajectory.y(cont)<g && Ion{conti}.trajectory.y(cont)>0
while Ion{conti}.trajectory.x(cont)<L && Ion{conti}.trajectory.y(cont)<g && Ion{conti}.trajectory.y(cont)>0
    
    %Increase X and Y positions for the HV cycle
    cont=cont+1;
    Ion{conti}.trajectory.y(cont)=Ion{conti}.trajectory.y(cont-1)+DeltayH;
    
    % Calculate variation of velocity in y
    Vrec=Vm.*(1-((4.*((Ion{conti}.trajectory.y(cont-1)-(g/2))^2))/(g^2)));
    %Position change in X due to the flow vel
    DeltaxH= Vrec*tH;
    Ion{conti}.trajectory.x(cont)=Ion{conti}.trajectory.x(cont-1)+DeltaxH;
    
    
    %If the ion reaches any of the boundaries break the while cycle
    if Ion{conti}.trajectory.x(cont)>L || Ion{conti}.trajectory.y(cont)>g || Ion{conti}.trajectory.y(cont)<0
       break
    end
   
    %Increase X and Y positions for the low V cycle
    cont=cont+1;
    Ion{conti}.trajectory.y(cont)=Ion{conti}.trajectory.y(cont-1)-Deltayl;
    
    % Calculate variation of velocity in y
    Vrec=Vm.*(1-((4.*((Ion{conti}.trajectory.y(cont-1)-(g/2))^2))/(g^2)));
    %Position change in X due to the flow vel
    Deltaxl= Vrec*tl;
    Ion{conti}.trajectory.x(cont)=Ion{conti}.trajectory.x(cont-1)+Deltaxl;
    
end
%time=(tH+tl)*(cont/2)
% After the while cycle, identify which id the first position with NaN
idx=find(isnan(Ion{conti}.trajectory.x),1,'first');
idy=find(isnan(Ion{conti}.trajectory.y),1,'first');


%Cuts the vector to leave only the positions with numbers.
Ion{conti}.trajectory.x=Ion{conti}.trajectory.x(1:idx-1);
Ion{conti}.trajectory.y=Ion{conti}.trajectory.y(1:idy-1);

if Flagsave>0
%Saves the lenght of the vector at the current CV
lxy(Cont2)=idx-1;
%Saves the X and Y data to write it in the excel fime
Mdat2x(1:lxy(Cont2),Cont2)=Ion{conti}.trajectory.x;
Mdat2y(1:lxy(Cont2),Cont2)=Ion{conti}.trajectory.y;
end

%Plot results
axes(v_serie);
%if the ion went completely through the ion filter then the plot line is blue, else, it is red
 if Ion{conti}.trajectory.x(idx-1)>L 
plot(Ion{conti}.trajectory.x, Ion{conti}.trajectory.y, 'b-')
SpecIon(Cont2)=SpecIon(Cont2)+1;

  else
 plot(Ion{conti}.trajectory.x, Ion{conti}.trajectory.y, 'r-')
% SpecIon(Cont2)=0;
 end
axis ([0 L 0 g])
ylabel('g (m)')
xlabel('L (m)')

% %Save the data in the excel file:
%  if Flagsave>0
%   TitleX= strcat('X - CV='+CV);
%   TitleY= strcat('Y - CV='+CV);
%   Mtit2((Cont2*2)-1)=TitleY;
%   Mtit2(Cont2*2)=TitleX;
%  Mdat2=[Ion{conti}.trajectory.y' Ion{conti}.trajectory.x'];
%  %Cont2 es el contador de CV
%  Columna=strcat('X - CV='+Cont2);
%  %conti es el contador de iones
%  sheet= strcat('Trajectories Ion'+conti);
%  %Write in the Excel file
%  xlswrite('SimData.xls', Mtit2, 'Spectrum', 'A1');
%  xlswrite('SimData.xls', Mdat2, 'Spectrum', 'A2');
% 
% end

%Increase CV for the next test
CV=CV+CVstep;
end

