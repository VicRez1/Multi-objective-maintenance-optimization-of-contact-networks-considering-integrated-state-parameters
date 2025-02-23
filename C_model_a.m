%这是输出总维护费用Csys的函数
%我们希望Csys越小越好

function Csys=C_model_a(x)
%初始化数据
RUL=110;
R_0=[0.99 0.99 0.99 0.99 0.99 0.85 0.85];
stage=floor(RUL/15)+1;
a = [143.47 171.32 179.21 175.18 171.62 91.5 85.5];
b = [4.55 21.12 5.25 9.14 6.57 2.5 2.3];
m1=1;m2=0.8;m3=0.8;m4=1;mj=0;
R0=zeros(7,stage);
Rf=zeros(7,stage);
Pj=zeros(7,stage,4);
P=zeros(7,stage);
k=0;

Cnj=[0 10 100 1000 ; 0 10 100 1000 ; 0 20 60 500 ; 0 2 8 80 ; 0 5 30 120 ; 0 8 20 40 ; 0 50 100 300];
Ch=[300 300 120 16 50 60 450];
times=zeros(7,4);
nwcost=zeros(1,7);
nqcost=zeros(1,7);
h=zeros(7);
Cw=0;
Cq=0;

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


%开始计算Rnkt
%第一步：初始化，第n个设备从第k=1阶段开始，初始可靠度R0(n,1)=R_0(n)，每阶段为15天
for n=1:7
    k=1;
    R0(n,1)=R_0(n);

%第二步：读取第1阶段的维修方案和相应的参数
    A=P(n,k);
    switch A
                case 1
                    Pj(n,k,1)=1;Pj(n,k,2)=0;Pj(n,k,3)=0;Pj(n,k,4)=0;mj=m1;
                case 2
                    Pj(n,k,1)=0;Pj(n,k,2)=1;Pj(n,k,3)=0;Pj(n,k,4)=0;mj=m2;
                case 3
                    Pj(n,k,1)=0;Pj(n,k,2)=0;Pj(n,k,3)=1;Pj(n,k,4)=0;mj=m3;
                case 4
                    Pj(n,k,1)=0;Pj(n,k,2)=0;Pj(n,k,3)=0;Pj(n,k,4)=1;mj=m4;
    end
    %接下来是k循环体，k=1：13 13要改
    while k
        %第四步：根据R0(n,k)得到该阶段最后的可靠度Rf(n,k)
        Rf(n,k)=R0(n,k)*exp(-(0.5/(mj*a(n))).^b(n));
        %第五步：进入下一阶段，共stage阶段
        k=k+1;
        if k>stage
            break;
        end
        %第六步：读取该阶段的维修方案
        A=P(n,k);
        switch A
                case 1
                    Pj(n,k,1)=1;Pj(n,k,2)=0;Pj(n,k,3)=0;Pj(n,k,4)=0;mj=m1;
                case 2
                    Pj(n,k,1)=0;Pj(n,k,2)=1;Pj(n,k,3)=0;Pj(n,k,4)=0;mj=m2;
                case 3
                    Pj(n,k,1)=0;Pj(n,k,2)=0;Pj(n,k,3)=1;Pj(n,k,4)=0;mj=m3;
                case 4
                    Pj(n,k,1)=0;Pj(n,k,2)=0;Pj(n,k,3)=0;Pj(n,k,4)=1;mj=m4;
        end
        %第七步：根据本阶段维修方案和上一阶段最后的可靠度，得到本阶段初始可靠度，然后返回第三步
        switch A
                case 1
                    R0(n,k)=Rf(n,k-1);
                case 2
                    R0(n,k)=Rf(n,k-1);
                case 3
                    R0(n,k)=Rf(n,k-1)+m2*(1-Rf(n,k-1));
                case 4
                    R0(n,k)=1;
        end
    end
end


%开始计算Csys，总维护费用C_sys=总维修费用Cw+总抢修费用Cq
%Cw为维修费用
%times表示第n个部件在整个RUL时间中使用第j种维修方式的次数
%ncost表示第n个部件在整个寿命中维修花的费用
for n=1:7
    for j=1:4
        for k=1:stage
            times(n,j)=times(n,j)+Pj(n,k,j);
        end
        nwcost(n)=nwcost(n)+times(n,j).*Cnj(n,j);
    end
    Cw=Cw+nwcost(n);
end
%Cq为抢修费用
%h为第n个在整个寿命中总的失效率
%nqcost为第n个部件的抢修费用
for n=1:7
    for k=1:stage
        h(n)=h(n)+(log(R0(n,k))-log(Rf(n,k)));
    end
    nqcost(n)=Ch(n).*h(n);
    Cq=Cq+nqcost(n);
end
Csys=Cw+Cq;