clear;
clc;
%M/M/1 with Bulk Service Simulation
K=input('Please Input Total Customer Number:'); %Total number of Customers
Lambda=1;%Arrival Rate
InterArrival_mean=1/Lambda;%inter arrival time mean as exponential distribution
Rho=zeros(1,10);%Utilization
W=zeros(1,10);
Wq=zeros(1,10);
T_W=zeros(1,10);
T_Wq=zeros(1,10);

for Rho_i=1:1:10
    Mu=Lambda/(Rho_i/10);%service rate
    Service_mean=1/Mu; %service time mean as exponential distribution
    
    Alpha=(sqrt(1+4*Lambda/Mu)-1)/2;
    T_Wq(Rho_i)=Alpha/((1-Alpha)*(Lambda+Mu*(1-Alpha)));
    T_W(Rho_i)=T_Wq(Rho_i)+Service_mean;

    Arrival_Time=zeros(1,K); 
    Leaving_Time=zeros(1,K);
    Arrival_Num=zeros(1,K);
    Leaving_Num=zeros(1,K);

    InterArrival_Time=exprnd(InterArrival_mean,1,K);
    Service_Time=exprnd(Service_mean,1,K);
    Arrival_Time(1)=InterArrival_Time(1);%initial value of Arrival time
    Arrival_Num(1)=1;%Arrival Number of Customer
    Leaving_Time(1)=Arrival_Time(1)+Service_Time(1);%initial value of Leaving time
    Leaving_Num(1)=1;%initial value of Leaving number
    
    for i=2:K
        Arrival_Time(i)=Arrival_Time(i-1)+InterArrival_Time(i);
        Arrival_Num(i)=i;
    end


    N=2;
    while N<K+1
        if  Leaving_Time(N-1)<=Arrival_Time(N)%after the N-1st customer leaves, the N+1st customer just arrives or haven't arrived yet.
            Leaving_Time(N)=Arrival_Time(N)+Service_Time(N);
            Leaving_Num(N)=N;
            N=N+1;
        elseif N<K&&Leaving_Time(N-1)>Arrival_Time(N+1)%after N-1st customer leaves, N+1st customer already in the Q
            Leaving_Time(N)=Leaving_Time(N-1)+Service_Time(N);
            Service_Time(N+1)=Service_Time(N);%the Nth customer and the N+1st customer share the server time      
            Leaving_Time(N+1)=Leaving_Time(N);      
            Leaving_Num(N)=N;
            Leaving_Num(N+1)=N+1;
            N=N+2;%loop to the N+2nd customer
        else %after the N-1st customer leaves, only Nth customer is in the system
            Leaving_Time(N)=Leaving_Time(N-1)+Service_Time(N);
            Leaving_Num(N)=N;
            N=N+1;%loop for 1
        end
    end



    W_Response=Leaving_Time-Arrival_Time; %Response Time in System
    Avg_W_Response=mean(W_Response);%Average Response Time in System
    W_Queue=W_Response-Service_Time;%Waiting Time in Queue
    Avg_W_Queue=mean(W_Queue);%Average Waiting Time in Queue

    Rho(Rho_i)=Rho_i/10;
    W(Rho_i)=Avg_W_Response;
    Wq(Rho_i)=Avg_W_Queue;
end

    figure(1);
    subplot(2,1,1);
    title('W');
    plot([0 Rho],[0 W],'r');
    hold on;
    plot([0 Rho],[0 T_W],'b');
    legend('simulated W','theoretical W');
    hold off;
    
    subplot(2,1,2);
    title('Wq');
    plot([0 Rho],[0 Wq],'r');
    hold on;
    plot([0 Rho],[0 T_Wq],'b');
    legend('simulated Wq','theoretical Wq');
    hold off;
    



    disp(['W=             ',num2str(roundn(W,-5))]);
    disp(['Theoretical W=    ',num2str(roundn(T_W,-5))]);
    disp(['Wq=            ',num2str(roundn(Wq,-5))]);
    disp(['Theoretical Wq=   ',num2str(roundn(T_Wq,-5))]);
