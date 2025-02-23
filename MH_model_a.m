%这是输出总工时MH的函数
%我们希望MH越小越好

function MH=MH_model_a(x)
%初始化数据
RUL=110;
stage=floor(RUL/15)+1;
Pj=zeros(7,stage,4);
P=zeros(7,stage);
k=0;
Hnj=[0 1/6 1/2 10 ; 0 1/6 1/2 10 ; 0 1/6 1/2 1/3 ; 0 1/6 1/2 1/2 ; 0 1/6 1/2 1 ; 0 1/6 1/2 1/2 ; 0 1/6 1/2 1/4];
times=zeros(7,4);
Hcost=zeros(1,7);
a=0;

%由于platemo无法设置整数，只能从布尔数转化为整数。00=1; 01=2; 10=3; 11=4
%向量x由platemo生成，这段代码将向量x转变为维修方案P
for n=1:2:14*stage
    if mod(n-1,2*stage)==0
        k=k+1;
    end
    if     x(n)==0 && x(n+1)==0
        P(k,((n+1)/2)-(k-1)*stage)=1;
    elseif x(n)==0 && x(n+1)==1
        P(k,((n+1)/2)-(k-1)*stage)=2;
    elseif x(n)==1 && x(n+1)==0
        P(k,((n+1)/2)-(k-1)*stage)=3;
    elseif x(n)==1 && x(n+1)==1
        P(k,((n+1)/2)-(k-1)*stage)=4;
    else
    end
end

%把维修方案P转化为Pj
for n=1:7
    for k=1:stage
        A=P(n,k);
        switch A
                case 1
                    Pj(n,k,1)=1;Pj(n,k,2)=0;Pj(n,k,3)=0;Pj(n,k,4)=0;
                case 2
                    Pj(n,k,1)=0;Pj(n,k,2)=1;Pj(n,k,3)=0;Pj(n,k,4)=0;
                case 3
                    Pj(n,k,1)=0;Pj(n,k,2)=0;Pj(n,k,3)=1;Pj(n,k,4)=0;
                case 4
                    Pj(n,k,1)=0;Pj(n,k,2)=0;Pj(n,k,3)=0;Pj(n,k,4)=1;
        end
    end
end

%开始计算工时MH
%times表示第n个部件在整个RUL时间中使用第j种维修方式的次数
%Hcost表示第n个部件在整个RUL时间中维修花费的工时
for n=1:7
    for j=1:4
        for k=1:stage
            times(n,j)=times(n,j)+Pj(n,k,j);
        end
        Hcost(n)=Hcost(n)+times(n,j).*Hnj(n,j);
    end
    a=a+Hcost(n);
end
MH=12*a;
