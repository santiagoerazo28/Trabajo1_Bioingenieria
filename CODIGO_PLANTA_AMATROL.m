close all
clear all
clc

% CÓDIGO PARA LA PLANTA AMATROL
% SINTESIS POR REALIMENTACION METODO DE DAHLIN
km=1.2358;
t0m=137.96;
taum=462.97;
Tau_C=0.5;
K_convercion= 0.1;
K_dh=taum/(km*(Tau_C+t0m));
Taui_dh=taum;
Taud_dh=t0m/2;
P_dh=K_dh;
I_dh=K_dh/Taui_dh;
D_dh=K_dh*Taud_dh;

% Para flujo usamos método amigo
km1=0.0320;
t0m1=0.93;
taum1=0.55;
k_AMI=(1/km1)*(0.2+0.45*(taum1/t0m1));
Ti_AMI=((0.4*t0m1+0.8*taum1)/(t0m1+0.1*taum1))*t0m1;
Td_AMI=((0.5*t0m1*taum1)/((0.3*t0m1)+taum1));
P_AMI=k_AMI;
I_AMI=k_AMI/Ti_AMI;
D_AMI=k_AMI*Td_AMI;

% Ejecutar la simulación y exportar los datos a MATLAB
simOut = sim('Simulink_Planta_Amatrol'); % Ejecuta la simulación

% Acceder a los datos de la variable 'datos_simulacion' que viene del bloque To Workspace
tiempo_sim = simOut.get('datos_simulacion').time;            % Tiempo de la simulación
nivel_tk1_sim = simOut.get('datos_simulacion').signals.values; % Valores simulados

% Datos reales para comparar
tiempo = [0:1:10, 20:10:100, 120:20:300, 350:50:1000, 1100:100:2000, 2200:200:4000];

% Datos de nivel_tk1
nivel_tk1 = [14.535; 14.79; 14.535; 14.535; 14.79; 14.79; 14.79; 14.79; 14.79; 14.79; 
    15.045; 15.3; 15.555; 16.065; 16.32; 16.575; 17.085; 17.34; 17.85; 18.105; 
    18.615; 19.38; 19.38; 19.38; 19.125; 19.125; 19.38; 19.38; 19.125; 19.38; 
    19.38; 19.125; 19.38; 19.125; 19.38; 19.38; 19.125; 19.125; 19.125; 19.125; 
    19.38; 19.38; 19.38; 19.125; 19.38; 19.38; 19.38; 19.125; 19.125; 19.38; 
    19.125; 19.38; 19.38; 19.125; 19.125; 19.125; 19.38; 19.38; 19.38; 19.38; 
    19.38; 19.38; 19.125; 19.38];

% Ajustar nivel_tk1 a la longitud de tiempo
if length(nivel_tk1) < length(tiempo)
    nivel_tk1 = [nivel_tk1; repmat(nivel_tk1(end), length(tiempo) - length(nivel_tk1), 1)];
elseif length(nivel_tk1) > length(tiempo)
    nivel_tk1 = nivel_tk1(1:length(tiempo));
end

sp = ones(size(tiempo)) * 15;
sp(tiempo > 1) = 19;

% Interpolación de los datos simulados para los tiempos especificados
nivel_tk1_sim_interp = interp1(tiempo_sim, nivel_tk1_sim, tiempo, 'linear');

% Verificar tamaños
disp(['Tamaño de tiempo: ', num2str(length(tiempo))]);
disp(['Tamaño de nivel_tk1: ', num2str(length(nivel_tk1))]);
disp(['Tamaño de nivel_tk1_sim_interp: ', num2str(length(nivel_tk1_sim_interp))]);

% Graficar los datos reales y simulados
figure;
plot(tiempo, nivel_tk1, 'b-', 'LineWidth', 1.5); % Datos reales de Nivel TK1
hold on;
plot(tiempo, sp, 'g--', 'LineWidth', 1.5);       % Línea constante SP
plot(tiempo, nivel_tk1_sim_interp, 'r-', 'LineWidth', 1.5); % Datos simulados interpolados
hold off;

% Personalizar el gráfico
xlabel('Tiempo (s)');
ylabel('Nivel (cm)');
title('Comparación de Datos Reales y Simulados - Nivel TK1');
legend('Nivel TK1 (Real)', 'SP', 'Nivel TK1 (Simulado)');
grid on;

% Datos de flujo
flujo = [
    1.419; 1.056; 0.8745; 1.287; 1.419; 1.419; 1.452; 1.485; 1.5015; 1.518; 
    1.518; 1.518; 1.518; 1.518; 1.518; 1.518; 1.518; 1.5015; 1.5345; 1.518; 
    1.518; 1.5015; 1.386; 1.287; 1.254; 0.726; 1.221; 1.3035; 1.353; 0.8745; 
    0.9075; 1.1385; 1.2375; 1.32; 1.3695; 0.858; 0.792; 1.1385; 1.221; 1.3035; 
    1.353; 0.9405; 0.726; 1.1385; 1.2705; 1.3365; 1.3695; 0.858; 0.726; 1.1055; 
    1.254; 1.3035; 0.99; 0.726; 1.221; 1.3035; 1.353; 0.8745; 0.9075; 1.1385; 
    1.2375; 1.32; 1.3695; 1.155
];

% Ajustar flujo a la longitud de tiempo (rellenar con el último valor si es necesario)
if length(flujo) < length(tiempo)
    flujo = [flujo; repmat(flujo(end), length(tiempo) - length(flujo), 1)];
elseif length(flujo) > length(tiempo)
    flujo = flujo(1:length(tiempo));
end

% Acceder a los datos de flujo y set_point_flujo
flujo_sim = simOut.get('datos_simulacion_2').signals.values; % Valores simulados de flujo
set_point_flujo = simOut.get('set_point_flujo').signals.values; % Obtener el set point de flujo

% Interpolación de los datos de flujo para los tiempos especificados
flujo_sim_interp = interp1(tiempo_sim, flujo_sim, tiempo, 'linear');
set_point_flujo_interp = interp1(tiempo_sim, set_point_flujo, tiempo, 'linear'); % Interpolar el set point de flujo

% Graficar los datos de flujo
figure;
plot(tiempo, flujo, 'b-', 'LineWidth', 1.5); % Datos reales de flujo
hold on;
plot(tiempo, flujo_sim_interp, 'r-', 'LineWidth', 1.5); % Datos simulados de flujo
plot(tiempo, set_point_flujo_interp, 'g--', 'LineWidth', 1.5); % Set point de flujo
xlabel('Tiempo (s)');
ylabel('Flujo (gpm)');
title('Comparación de Datos Reales, Simulados y Set Point para Flujo');
legend('Flujo (Real)', 'Flujo (Simulado)', 'Set Point (Flujo)');
grid on;

