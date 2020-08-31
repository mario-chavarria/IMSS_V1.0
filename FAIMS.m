function FAIMS(action)
% High-Field Asymmetric Waveform Ion Mobility Spectrometry simulation software.

global Mx RE IM Wx ModZ flagwf CAP CON posx posy NIons Cont2 Falco_handle Vin tvect
global  handle_CVstep handle_CVmin handle_CVmax CVstep CVmin CVmax lxy Ideal_handle
global handle_Vm handle_Vpp handle_n handle_g handle_L handle_a2 handle_a4 handle_Ko handle_freq handle_DtC
global Vm Vpp n g L a2 a4 Ko freq DtC Ion conti SpecIon Flagret2 Flagsave tH tl tstep
global figNumber v_serieIM v_serieLOG Flagret SpecCV Yo handle_Ions Mtit2 Mdat2x Mdat2y
% Manejador del eje
global v_serie v_serie2; %v_serie3 v_serie4 v_serie5;

if nargin < 1, action = 'inicializar'; end;
if strcmp(action,'inicializar'),
% Aqui se crean los objetos que van a conformar nuestra interfaz con el usuario

%Ventana emergente inicial
H_FIG_Splash=figure('Name','iMSS 1.0','NumberTitle','off','MenuBar','none','Units','normalized','Position',[0.2 0.25 0.26 0.255],'Visible','off');


figure(H_FIG_Splash);
v_serieIM = axes( 'Units','normalized','Position',[0 0 1 1], 'Box','on');
axes(v_serieIM);
Ima=imread('pressplash','jpg');
image(Ima);axis off;
plotedit(H_FIG_Splash,'HIDETOOLSMENU')
pause(2);
close(H_FIG_Splash);


%Inicializamos el espacio para graficar
figNumber=figure('Name','FAIMS 1.0','Color',[0.9 0.9 0.9], 'NumberTitle','off','MenuBar','none','Units','normalized','Position',[0.01 0.01 0.9 0.9]);
% Definición de los ejes en donde va la gráfica
v_serie = axes( 'Units','normalized', 'Position',[0.05 0.6 0.5 0.3], 'Box','on');
v_serie2 = axes( 'Units','normalized', 'Position',[0.58 0.15 0.37 0.35], 'Box','on');


v_serieLOG = axes( 'Units','normalized', 'Position',[0.75 0.93 0.105 0.061], 'Box','on');

axes(v_serieLOG);
Ima=imread('EPFL','jpg');
image(Ima);axis off;

v_serieECU = axes( 'Units','normalized', 'Position',[0.035 0.2 0.5 0.25], 'Box','on');

axes(v_serieECU);
Ima=imread('FAIMSsch','jpg');
image(Ima);axis off;

v_serieIDEAL = axes( 'Units','normalized', 'Position',[0.2 0.47 0.06 0.055], 'Box','on');

axes(v_serieIDEAL);
Ima=imread('Ideal','jpg');
image(Ima);axis off;

v_serieNONIDEAL = axes( 'Units','normalized', 'Position',[0.3 0.47 0.06 0.055], 'Box','on');

axes(v_serieNONIDEAL);
Ima=imread('NON-Ideal','jpg');
image(Ima);axis off;

% v_serieELEC = axes( 'Units','normalized', 'Position',[0.695 0.19 0.3 0.13], 'Box','on');
% 
% axes(v_serieELEC);
% Ima=imread('eleg','jpg');
% image(Ima);axis off;

Flagret=0; Flagret2=0; Flagsave=0; flagwf=0; RE=0; IM=0; g=0; L=0;  a2=0;  Vm=0;  Vpp=0;  n=0; 

%Creamos el Menu de opciones 

  h_menu_1 = uimenu('Label','File');
     callbackStr='FAIMS(''Cargar'');';   
     h_menu_1_1= uimenu(h_menu_1,'Label','Save: Ion trajectories','Callback',callbackStr);
     callbackStr='FAIMS(''spectrum'');';   
     h_menu_1_1= uimenu(h_menu_1,'Label','Save: Spectrum','Callback',callbackStr); 
     callbackStr='FAIMS(''Print'');';   
     h_menu_1_2= uimenu(h_menu_1,'Label','Print', 'Callback',callbackStr);
     callbackStr='FAIMS(''spectrum'');';       
     h_menu_1_3=uimenu(h_menu_1,'Label','Close','Callback',callbackStr);   

  h_menu_2 = uimenu('Label','Options');
     
     callbackStr='FAIMS(''simular'');';   
     h_menu_2_1= uimenu(h_menu_2,'Label','Simulate', 'Callback',callbackStr);
     callbackStr='FAIMS(''Retener'');';   
     h_menu_2_2= uimenu(h_menu_2,'Label','Hold', 'Callback',callbackStr);

     
  h_menu_3 = uimenu('Label','help');
     callbackStr='FAIMS(''help'');';       
     h_menu_3_1=uimenu(h_menu_3,'Label','Help...','Callback',callbackStr); 
     callbackStr='FAIMS(''about'');';       
     h_menu_3_2=uimenu(h_menu_3,'Label','About iMSS 1.0','Callback',callbackStr); 
     
%Creamos un boton para graficar la función
left=0.121;
yPos=0.02;
btnWid=0.043;
btnHt=0.06;
btnPos=[left yPos btnWid btnHt];
%labelStr='Simular';
cmdStr='simular';
callbackStr='FAIMS(''simular'');';
btnPos=[left yPos btnWid btnHt];
Gra_handle=uicontrol( 'Style','pushbutton', 'Units','normalized', 'Position',btnPos,  'Value',1,'TooltipString','Graph', 'Callback',callbackStr);

%Creamos un boton para retener o no la gráfica
left=0.264;
btnPos=[left yPos btnWid btnHt];
%labelStr='Retener';
callbackStr='FAIMS(''Retener'');';
btnPos=[left yPos btnWid btnHt];
Ret_handle=uicontrol( 'Style','pushbutton', 'Units','normalized', 'Position',btnPos, 'Value',1,'TooltipString','Hold', 'Callback',callbackStr);

%Creamos un boton para Save data trayectory X and Y
left=0.407;
btnPos=[left yPos btnWid btnHt];
%labelStr='Cargar';
callbackStr='FAIMS(''Cargar'');';
btnPos=[left yPos btnWid btnHt];
Carg_handle=uicontrol( 'Style','pushbutton', 'Units','normalized', 'Position',btnPos,  'Value',1,'TooltipString','Save data: ion trajectories', 'Callback',callbackStr);


% Creamos el boton de Save data spectrum
left=0.55;
%labelStr='Salir';
btnPos=[left yPos btnWid btnHt];
callbackStr='FAIMS(''spectrum'');';
Sal_handle=uicontrol( 'Style','pushbutton', 'Units','normalized', 'Position',btnPos, 'Value',1,'TooltipString','Save data: Detected spectrum', 'Callback',callbackStr);

%Creamos un boton para el Hold spectrum
left=0.693;
btnPos=[left yPos btnWid btnHt];
%labelStr='Simular';
cmdStr='HSpect';
callbackStr='FAIMS(''HSpect'');';
btnPos=[left yPos btnWid btnHt];
Hold2_handle=uicontrol( 'Style','pushbutton', 'Units','normalized', 'Position',btnPos,  'Value',1,'TooltipString','Hold Spectrum', 'Callback',callbackStr);

% Creamos el boton de impresión
left=0.836;
%labelStr='Imprimir';
btnPos=[left yPos btnWid btnHt];
callbackStr='FAIMS(''Print'');';
print_handle=uicontrol( 'Style','pushbutton', 'Units','normalized', 'Position',btnPos, 'Value',1, 'TooltipString','Print', 'Callback',callbackStr);

% Creamos el boton de Eraser
left=0.335;
yPos=0.91;
btnWid=0.03;
btnHt=0.041;
btnPos=[left yPos btnWid btnHt];
callbackStr='FAIMS(''Eraser1'');';
Eraser_handle= uicontrol( 'Style','pushbutton', 'Units','normalized', 'Position',btnPos,  'Interruptible','on','TooltipString','Erase', 'Callback',callbackStr);

% Creamos el boton de Seleccionar funcion ideal
left=0.265;
yPos=0.482;
btnWid=0.008;
btnHt=0.02;
btnPos=[left yPos btnWid btnHt];
callbackStr='FAIMS(''fideal'');';
Ideal_handle= uicontrol( 'Style','radiobutton', 'Units','normalized', 'Position',btnPos,  'Value',1, 'Interruptible','on','TooltipString','Ideal waveform', 'Callback',callbackStr);

% Creamos el boton de Seleccionar falco amp
left=0.365;
yPos=0.482;
btnWid=0.008;
btnHt=0.02;
btnPos=[left yPos btnWid btnHt];
callbackStr='FAIMS(''ffalco'');';
Falco_handle= uicontrol( 'Style','radiobutton', 'Units','normalized', 'Position',btnPos,  'Value',0, 'Interruptible','on','TooltipString','Falco amp. waveform', 'Callback',callbackStr);


%Insertamos la imagen a los botones 
Ima=imread('Eraser-icon','jpg');
set(Eraser_handle,'CData',Ima);
Ima=imread('save-spec','jpg');
 set(Sal_handle,'CData',Ima);
Ima=imread('Save-tray','jpg');
 set(Carg_handle,'CData',Ima);
Ima=imread('Plot_Icon','jpg');
 set(Gra_handle,'CData',Ima); 
Ima=imread('Hold_Icon','jpg');
 set(Ret_handle,'CData',Ima); 
Ima=imread('printjpg','jpg');
set(print_handle,'CData',Ima); 
Ima=imread('Hold2_Icon','jpg');
set(Hold2_handle,'CData',Ima); 

%Creamos un edit para entrar el Vm
left=0.65;
yPos=0.87;
btnWid=0.1;
btnHt=0.03;
btnPos=[left yPos btnWid btnHt]; 

handle_Vm=uicontrol( 'Style','Edit', 'Units','normalized', 'Position',btnPos, 'String','0');
Vm_text = uicontrol('ForegroundColor',[ 0 0 0 ], 'Units','normalized', 'Position',[ 0.58 0.87 0.06 0.03],'String','Vm: Max Flow Velocity[m/s]', 'Style','text');

%Creamos un edit para entrar el g
left=0.65;
yPos=0.82;
btnWid=0.1;
btnHt=0.03;
btnPos=[left yPos btnWid btnHt]; 

handle_g=uicontrol( 'Style','Edit', 'Units','normalized', 'Position',btnPos, 'String','0');
g_text = uicontrol('ForegroundColor',[ 0 0 0 ], 'Units','normalized', 'Position',[ 0.58 0.82 0.06 0.03],'String','g: Gap height [m]', 'Style','text');

%Creamos un edit para entrar el Vpp
left=0.65;
yPos=0.77;
btnWid=0.1;
btnHt=0.03;
btnPos=[left yPos btnWid btnHt]; 

handle_Vpp=uicontrol( 'Style','Edit', 'Units','normalized', 'Position',btnPos, 'String','0');
Vpp_text = uicontrol('ForegroundColor',[ 0 0 0 ], 'Units','normalized', 'Position',[ 0.58 0.77 0.06 0.03],'String','Vpp: Voltage peak to peak [V]', 'Style','text');

%Creamos un edit para entrar el L
left=0.65;
yPos=0.72;
btnWid=0.1;
btnHt=0.03;
btnPos=[left yPos btnWid btnHt]; 

handle_L=uicontrol( 'Style','Edit', 'Units','normalized', 'Position',btnPos, 'String','0');
L_text = uicontrol('ForegroundColor',[ 0 0 0 ], 'Units','normalized', 'Position',[ 0.58 0.72 0.06 0.03],'String','L: Ion filter length [m]', 'Style','text');

%Creamos un edit para entrar el n
left=0.65;
yPos=0.67;
btnWid=0.1;
btnHt=0.03;
btnPos=[left yPos btnWid btnHt]; 

handle_n=uicontrol( 'Style','Edit', 'Units','normalized', 'Position',btnPos, 'String','0');
n_text = uicontrol('ForegroundColor',[ 0 0 0 ], 'Units','normalized', 'Position',[ 0.58 0.67 0.06 0.03],'String','n: Number density [1/m3]', 'Style','text');

%Creamos un edit para entrar el a2
left=0.85;
yPos=0.87;
btnWid=0.1;
btnHt=0.03;
btnPos=[left yPos btnWid btnHt]; 

handle_a2=uicontrol( 'Style','Edit', 'Units','normalized', 'Position',btnPos, 'String','0');
a2_text = uicontrol('ForegroundColor',[ 0 0 0 ], 'Units','normalized', 'Position',[ 0.78 0.87 0.06 0.03],'String','Alpha 2', 'Style','text');


%Creamos un edit para entrar el a4
left=0.85;
yPos=0.82;
btnWid=0.1;
btnHt=0.03;
btnPos=[left yPos btnWid btnHt]; 

handle_a4=uicontrol( 'Style','Edit', 'Units','normalized', 'Position',btnPos, 'String','0');
a4_text = uicontrol('ForegroundColor',[ 0 0 0 ], 'Units','normalized', 'Position',[ 0.78 0.82 0.06 0.03],'String','Alpha 4', 'Style','text');

%Creamos un edit para entrar el Ko
left=0.85;
yPos=0.77;
btnWid=0.1;
btnHt=0.03;
btnPos=[left yPos btnWid btnHt]; 

handle_Ko=uicontrol( 'Style','Edit', 'Units','normalized', 'Position',btnPos, 'String','0');
Ko_text = uicontrol('ForegroundColor',[ 0 0 0 ], 'Units','normalized', 'Position',[ 0.78 0.77 0.06 0.03],'String','Ko: Ion mobility [m2/Vs]', 'Style','text');

%Creamos un edit para entrar el freq
left=0.85;
yPos=0.72;
btnWid=0.1;
btnHt=0.03;
btnPos=[left yPos btnWid btnHt]; 

handle_freq=uicontrol( 'Style','Edit', 'Units','normalized', 'Position',btnPos, 'String','0');
freq_text = uicontrol('ForegroundColor',[ 0 0 0 ], 'Units','normalized', 'Position',[ 0.78 0.72 0.06 0.03],'String','Frequency [Hz]', 'Style','text');

%Creamos un edit para entrar el DtC
left=0.85;
yPos=0.67;
btnWid=0.1;
btnHt=0.03;
btnPos=[left yPos btnWid btnHt]; 

handle_DtC=uicontrol( 'Style','Edit', 'Units','normalized', 'Position',btnPos, 'String','0');
DtC_text = uicontrol('ForegroundColor',[ 0 0 0 ], 'Units','normalized', 'Position',[ 0.78 0.67 0.06 0.03],'String','Duty cycle [%]', 'Style','text');


%Creamos un edit para entrar el CV min
left=0.65;
yPos=0.58;
btnWid=0.1;
btnHt=0.03;
btnPos=[left yPos btnWid btnHt]; 

handle_CVmin=uicontrol( 'Style','Edit', 'Units','normalized', 'Position',btnPos, 'String','0');
CVmin_text = uicontrol('ForegroundColor',[ 0 0 0 ], 'Units','normalized', 'Position',[ 0.58 0.58 0.06 0.03],'String','CV Min [V]', 'Style','text');
CV_text = uicontrol('ForegroundColor',[ 0 0 0 ], 'Units','normalized', 'Position',[ 0.58 0.62 0.10 0.02],'String','Compensation voltage (CV):', 'Style','text');

%Creamos un edit para entrar el CV max
left=0.85;
yPos=0.58;
btnWid=0.1;
btnHt=0.03;
btnPos=[left yPos btnWid btnHt]; 

handle_CVmax=uicontrol( 'Style','Edit', 'Units','normalized', 'Position',btnPos, 'String','0');
CVmax_text = uicontrol('ForegroundColor',[ 0 0 0 ], 'Units','normalized', 'Position',[ 0.78 0.58 0.06 0.03],'String','CV Max [V]', 'Style','text');

%Creamos un edit para entrar el CV step
left=0.75;
yPos=0.53;
btnWid=0.1;
btnHt=0.03;
btnPos=[left yPos btnWid btnHt]; 

handle_CVstep=uicontrol( 'Style','Edit', 'Units','normalized', 'Position',btnPos, 'String','0');
CVstep_text = uicontrol('ForegroundColor',[ 0 0 0 ], 'Units','normalized', 'Position',[ 0.68 0.53 0.06 0.03],'String','CV Step size [V]', 'Style','text');

%Creamos un edit para entrar el Number of ions
left=0.275;
yPos=0.91;
btnWid=0.05;
btnHt=0.03;
btnPos=[left yPos btnWid btnHt]; 

handle_Ions=uicontrol( 'Style','Edit', 'Units','normalized', 'Position',btnPos, 'String','0');
Ions_text = uicontrol('ForegroundColor',[ 0 0 0 ], 'Units','normalized', 'Position',[ 0.23 0.91 0.04 0.03],'String','Number of Ions', 'Style','text');

%Respuesta del llamado del botón de simulación
elseif strcmp(action,'simular');
    %Capturamos los datos ingresados por el usuario
    Vm = str2num(get(handle_Vm,'String'));
    Vpp = str2num(get(handle_Vpp,'String'));
    n = str2num(get(handle_n,'String'));
    g = str2num(get(handle_g,'String'));
    L = str2num(get(handle_L,'String'));
    a20 = str2num(get(handle_a2,'String'));
    a2 = a20*(-1);
    a40 = str2num(get(handle_a4,'String'));
    a4 = a40*(-1);
    Ko = str2num(get(handle_Ko,'String'));
    freq = str2num(get(handle_freq,'String'));
    DtC = str2num(get(handle_DtC,'String'));
    CVmax = str2num(get(handle_CVmax,'String'));
    CVmin = str2num(get(handle_CVmin,'String'));
    CVstep = str2num(get(handle_CVstep,'String'));
    NIons= str2num(get(handle_Ions,'String'));
    
    %Progress Bar
    PBar = waitbar(0, 'Starting...'); 
    
    %calculate the non ideal voltage waveform
    if flagwf>0
    t1k=(0:1:1000);
    tvect=(0:((1/freq)/1000):(1/freq));
    tstep=(1/freq)/1000;
    WF = (0.5.*cos(4.41 + 0.005967.*t1k + 0.02001.*sin(t1k)) - 0.2376.*cos(2.373.*cos(4.503 + 0.005875.*t1k)))-0.0165;
    Vin=Vpp.*WF;
    else
        %Time High
        tH=(1/freq)*(DtC/100);
        %Time low
        tl=(1/freq)*(1-(DtC/100));
    end
    
    Contcycles=0;
%     %Title columns trayectories in excel
%     Mtit2=NaN(1,((((CVmax-CVmin)/CVstep+1)*2)));
    %divide the gap in 11 sections to place the 10 ions to simulate
    spacer= g/(NIons+1);
    Yo=0;
    conti=0;
    %Vectors for the Detected Spectrum
    SpecCV=(CVmin:CVstep:CVmax);
    SpecIon=zeros(1,length(SpecCV));
    
    while conti<NIons
        Yo=Yo+spacer;
        Contcycles=Contcycles+1
       % waitbar((Contcycles/NIons), PBar, 'Simulation progress:');
        conti=conti+1;
        %Vector for the lengt of the different X and Y vectors of all CVs
        MODCV=(CVmax-CVmin)/CVstep;
        if mod(MODCV,1) ~= 0
            HMess=helpdlg('[(CVmax-CVmin)/CVstep] should be an integer');
        end
        lxy=NaN((((CVmax-CVmin)/CVstep)+1),1);
        
        Mdat2x=NaN(1000000,(((CVmax-CVmin)/CVstep)+1));
        Mdat2y=NaN(1000000,(((CVmax-CVmin)/CVstep)+1));
        Sim
        waitbar((Contcycles/NIons), PBar, 'Simulation progress:');
         %Save the data in the excel file:
          if Flagsave>0   
          Mtit2=(CVmin:CVstep:CVmax);
          Mdat2x=Mdat2x(1:max(lxy),:); 
          Mdat2y=Mdat2y(1:max(lxy),:);
          %conti es el contador de iones
          StrCont=num2str(conti);
          sheety= strcat('Y Ion ', StrCont);
          sheetx= strcat('X Ion ', StrCont);
          %Write in the Excel file
          xlswrite('SimData.xls', Mtit2, sheety, 'A1');
%          Mdat2y=Ion{conti}.trajectory.y
          xlswrite('SimData.xls', Mdat2y, sheety, 'A2');
          xlswrite('SimData.xls', Mtit2, sheetx, 'A1');
          xlswrite('SimData.xls', Mdat2x, sheetx, 'A2');
        
        end
    end
%Plot Spectrum
axes(v_serie2);
plot(SpecCV, SpecIon, 'k-')
axis ([CVmin CVmax 0 NIons])
ylabel('Ions')
xlabel('Compensation Voltage [V]')

elseif strcmp(action,'Retener');
    axes(v_serie);
    hold
if Flagret<1
    Flagret=1;
    HMess=helpdlg('   Plots held');
else
    Flagret=0;
    HMess=helpdlg('   Plots released');
end


%Respuesta del llamado del botón de imprimir
elseif strcmp(action,'Print');
print ('PrtScn','-dpng') ;
%Respuesta del llamado del botón de cargar
elseif strcmp(action,'Cargar');

if Flagsave<1
    Flagsave=1;
    HMess=helpdlg('Simulated ion trajectories will be saved from now on!');
else
    Flagsave=0;
    HMess=helpdlg('Simulated ion trajectories wont be saved from now on!');
end
 
%Respuesta del llamado del botón de eraser
elseif strcmp(action,'Eraser1');
cla(v_serie,'reset')
 
if Flagret>0
    axes(v_serie);
    hold
end

%Respuesta del llamado del botón de dielec
elseif strcmp(action,'HSpect');
 axes(v_serie2);
    hold
if Flagret2<1
    Flagret2=1;
    HMess=helpdlg('   Plots held');
else
    Flagret2=0;
    HMess=helpdlg('   Plots released');
end

%respuesta Help
elseif strcmp(action,'help'),	

infoStr= ...                                            
        ['                                                               '
         'INPUT DATA: All data requested for the simulation must be input' 
         'in the edit fields in the right side of the screen.            '                
         '                                                               '                              
         'NUMBER OF IONS: The  number of ions must  be an  integer higher'            
         'than 0. If a value with decimals is introduced, the system will'  
         'increase it to  the  next  higher  integer.  The  software will'  
         'distribute the ions equidistantly along the gap.               '            
         '                                                               '];          

helpwin(infoStr, 'iMSS V1: Ion Mobility Simulation Software');  

%respuesta About
elseif strcmp(action,'about'),	

infoStr2= ...                                            
        ['                                                       ' 
         ' ***************************************************** '
         '     **  **    **   *****   *****   **        **       '
         '     **  ***  ***  **      **      ***      **  **     '
         '         ** ** **  **      **       **      **  **     '
         '    ***  **    **   ****    ****    **      **  **     ' 
         '     **  **    **      **      **   **      **  **     ' 
         '     **  **    **      **      **   **  **  **  **     '
         '     *** **    **  *****   *****    **  **    **       ' 
         ' ***************************************************** '
         '                                                       ' 
         ' iMSS V1: Ion Mobility Simulation Software             '  
         ' Version: 1.0                                          '
         '                                                       ' 
         ' Autor:  Mario Andres Chavarria Varon                  '                               
         '                                                       '
         ' École polytechnique fédérale de Lausanne EPFL         '
         '                                                       '
         ' Lausanne, Switzerland                                 '];  

helpwin(infoStr2, 'About iMSS 1.0');

%Respuesta del llamado del botón de salir
elseif strcmp(action,'spectrum');

%Creamos el archivo de Excel con los datos calculados
 Mtit={'Compensation Voltage (V)', 'Detected Ions'};
 Mdat=[SpecCV' SpecIon'];
 
 xlswrite('SimData.xls', Mtit, 'Spectrum', 'A1');
 xlswrite('SimData.xls', Mdat, 'Spectrum', 'A2');
 HMess=helpdlg('   Spectrum data saved');

 elseif strcmp(action,'fideal');
 flagwf=0;
 set(Falco_handle, 'Value', 0);
 
 elseif strcmp(action,'ffalco');
 flagwf=1;
 set(Ideal_handle, 'Value', 0);
 
end;