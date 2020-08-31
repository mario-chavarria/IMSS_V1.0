function Delta(action)
% High-Field Asymmetric Waveform Ion Mobility Spectrometry simulation software.

global Mx RE IM Wx ModZ Fase CAP CON %Ion{conti}.trajectory.x Ion{conti}.trajectory.y
global  handle_CVstep handle_CVmin handle_CVmax CVstep CVmin CVmax
global handle_Vm handle_Vpp handle_n handle_g handle_L handle_a2 handle_a4 handle_Ko handle_freq handle_DtC
global Vm Vpp n g L a2 a4 Ko freq DtC SpecCV Yo SpecIon Mtit2 lxy flagwf CV tH tl tvect Vin tstep
global figNumber v_serieIM v_serieLOG Flagret Ion conti Flagsave Mdat2x Mdat2y DeltayH Deltayl
% Manejador del eje
global v_serie v_serie2; %v_serie3 v_serie4 v_serie5;


%if the wave form is not ideal (divide it in 10 steps)
if flagwf>0
    
%Electric field  
EV=((Vin)+CV)./g;

%[E/N] in Td (E/N)/1e-21
ENV=EV./(n*1e-21);

%Alpha 
AlphaV=(a2.*(ENV).^2)+(a4.*(ENV).^4);

%Ion mobility 
KV=Ko.*(1+AlphaV);

%Position change in Y due to the electric field
DeltayV= KV.*EV.*tstep;
negativos=find(DeltayV<0);
positivos=find(DeltayV>0);
DeltayHV=DeltayV(positivos);
DeltaylV=DeltayV(negativos);
DeltayH=sum(DeltayHV);
Deltayl=(sum(DeltaylV))*(-1);


else %if the wave form is ideal
    
%Electric field High 
EH=((Vpp*(1-(DtC/100)))+CV)/g;
%Electric field low
El=((Vpp*(DtC/100))-CV)/g;

%[E/N]High in Td (E/N)/1e-21
ENH=EH/(n*1e-21);
%[E/N]Low in Td (E/N)/1e-21
ENl=El/(n*1e-21);

%Alpha High
AlphaH=(a2*(ENH)^2)+(a4*(ENH)^4);
%Alpha Low
Alphal=(a2*(ENl)^2)+(a4*(ENl)^4);

%Ion mobility High
KH=Ko*(1+AlphaH);
%Ion mobility Low
Kl=Ko*(1+Alphal);

%Position change in Y due to the electric field
DeltayH= KH*EH*tH;
Deltayl= Kl*El*tl;
end