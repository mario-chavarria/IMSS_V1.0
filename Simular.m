function Simular(action)
% High-Field Asymmetric Waveform Ion Mobility Spectrometry simulation software.

global Mx RE IM Wx ModZ Fase CAP CON posx posy
global  handle_CVstep handle_CVmin handle_CVmax CVstep CVmin CVmax
global handle_Vm handle_Vpp handle_n handle_g handle_L handle_a2 handle_a4 handle_Ko handle_freq handle_DtC
global Vm Vpp n g L a2 a4 Ko freq DtC
global figNumber v_serieIM v_serieLOG Flagret
% Manejador del eje
global v_serie v_serie2; %v_serie3 v_serie4 v_serie5;

%Capturamos los datos ingresados por el usuario
Vm = str2num(get(handle_Vm,'String'));
Vpp = str2num(get(handle_Vpp,'String'));
n = str2num(get(handle_n,'String'));

g = str2num(get(handle_g,'String'));
L = str2num(get(handle_L,'String'));
a2 = str2num(get(handle_a2,'String'));
a4 = str2num(get(handle_a4,'String'));
Ko = str2num(get(handle_Ko,'String'));
freq = str2num(get(handle_freq,'String'));
DtC = str2num(get(handle_DtC,'String'));
CVmax = str2num(get(handle_CVmax,'String'));
CVmin = str2num(get(handle_CVmin,'String'));
CVstep = str2num(get(handle_CVstep,'String'));

%Calculos teoricos
%Time High
tH=(1/freq)*(DtC/100);
%Time low
tl=(1/freq)*(1-(DtC/100));
%Compensation Voltage
CV=CVmin;
%Vectors for the Detected Spectrum
SpecCV=NaN((((CVmax-CVmin)/CVstep+1)),1);
SpecIon=NaN((((CVmax-CVmin)/CVstep+1)),1);
Cont2=0;
%while for the different CVs
while CV<=CVmax
    Cont2=Cont2+1;
%Electric field High
EH=((Vpp*(1-(DtC/100)))+CV)/g;
%Electric field low
El=((Vpp*(DtC/100))-CV)/g;

%[E/N]High
ENH=EH/(n*1e-21);
%[E/N]Low
ENl=El/(n*1e-21);

%Alpha High
AlphaH=(a2*(ENH)^2)+(a4*(ENH)^4);
%Alpha Low
Alphal=(a2*(ENl)^2)+(a4*(ENl)^4);

%Ion mobility High
KH=Ko*(1+AlphaH);
%Ion mobility Low
Kl=Ko*(1+Alphal);

%Calculate ion position

% Create 2 vectors of length 1000000 full with NaN

posx=NaN(1000000,1);
posy=NaN(1000000,1);
%Initial position
posx(1)=0;
posy(1)=g/2;

%Position change in Y due to the electric field
DeltayH= KH*EH*tH;
Deltayl= Kl*El*tl;

%Position change in X due to the flow vel

DeltaxH= Vm*tH;
Deltaxl= Vm*tl;

cont=1;
while posx(cont)<L && posy(cont)<g && posy(cont)>0
    
    %Increase X and Y positions for the HV cycle
    cont=cont+1;
    posy(cont)=posy(cont-1)+DeltayH;
    
    % Calculate variation of velocity in y
    Vrec=Vm.*(1-((4.*((posy(cont-1)-(g/2))^2))/(g^2)));
    %Position change in X due to the flow vel
    DeltaxH= Vrec*tH;
    posx(cont)=posx(cont-1)+DeltaxH;
    
    
    %If the ion reaches any of the boundaries break the while cycle
    if posx(cont)>L || posy(cont)>g || posy(cont)<0
       break
    end
   
    %Increase X and Y positions for the low V cycle
    cont=cont+1;
    posy(cont)=posy(cont-1)-Deltayl;
    
    % Calculate variation of velocity in y
    Vrec=Vm.*(1-((4.*((posy(cont-1)-(g/2))^2))/(g^2)));
    %Position change in X due to the flow vel
    Deltaxl= Vrec*tl;
    posx(cont)=posx(cont-1)+Deltaxl;
    
end

% After the while cycle, identify which id the first position with NaN
idx=find(isnan(posx),1,'first');
idy=find(isnan(posy),1,'first');
%Cuts the vector to leave only the positions with numbers.
posx=posx(1:idx-1);
posy=posy(1:idy-1);
end
