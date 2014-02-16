function ydot = ode_pinene(t,y,flag,teta1,teta2,teta3,teta4,teta5)

    ydot(1) = -(teta1+teta2)*y(1);
    ydot(2) = teta1*y(1);
    ydot(3) = teta2*y(1)-(teta3+teta4)*y(3)+teta5*y(5);
    ydot(4) = teta3*y(3);
    ydot(5) = teta4*y(3)-teta5*y(5);
    ydot=ydot';
end 