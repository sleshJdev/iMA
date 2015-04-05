classdef AnsysRunner
    %ANSYSRUNNER Replesent interface to run AnsysWorkbench and pass to him
    %            IronPython script and ansys project
    
    properties (Access = private)
        ansysExePath;
        ansysProjectPath;
        scriptPath;
    end
    
    methods(Access = private)
        function [command] = buildRunCommand(this)
            command = sprintf('"%s" -X -R %s -F %s', this.ansysExePath, this.scriptPath, this.ansysProjectPath);
        end
    end
    
    methods
        function this = AnsysRunner(ansysExePath, scriptPath, ansysProjectPath)
            this.ansysExePath = ansysExePath;
            this.scriptPath = scriptPath;
            this.ansysProjectPath = ansysProjectPath;
        end
        function [totalDeformation] = run(this, inVector, constantPressure)                
            global PROPERTIES;   
                        
            excel = Excel(fullfile(PROPERTIES.excelSheetPath, PROPERTIES.excelSheetName));
            
            excel.setValueOfParameter('Length', inVector(1));
            excel.setValueOfParameter('Width', inVector(2));
            excel.setValueOfParameter('Height', inVector(3));     
            
            if ( nargin == 3 )
                excel.setValueOfParameter('Height', constantPressure);
            end
            
            command = this.buildRunCommand();
            
            Logger.info(sprintf('AnsysRunner    run    command: %s', command));
            
            system(command);               
            
            totalDeformation = excel.getValueOfParameter('Deformation');          
        end
        
        function res = rosenbrok(this, x0,N,a,b,xmax,xmin,e1,dx0)           
            %x0 - �����. ����. N-����. ���. ������.
            %a,b - ����. ������ � ������. xmin, xmax - ������� ������, dx - ���� �� ������������
            k=0;l=0;isEndWhile=0;
            dx=dx0;
            d1=[1 0 0];%��������� �����������
            d2=[0 1 0];
            d3=[0 0 1];
            lambda=[0 0 0];
            d=[d1; d2; d3];
            xk=x0;
            % yk= myFunc(x0);
            yk = this.run(x0);
            vy = [x0 yk];
            
            disp('RESULT______________');
            disp(yk);
            disp(vy);   
            
            % while isEndWhile==0
            %     yn=myFunc(x0);
            %        for i=1:1:3
            %         x1=x0;
            %         x1(1)=x1(1)+d(i,1)*dx(i);
            %         x1(2)=x1(2)+d(i,2)*dx(i);
            %         x1(3)=x1(3)+d(i,3)*dx(i);
            %         if((x1(1)>xmin(1))&&(x1(2)>xmin(2))&&(x1(3)>xmin(3))&&(x1(1)<xmax(1))&&(x1(2)<xmax(2))&&(x1(3)<xmax(3)))
            %         y1=myFunc(x1);
            %         k=k+1;
            %         y0=myFunc(x0);
            %         if(y1<y0)
            %             x0=x1;
            %             lambda(i)=lambda(i)+dx(i);
            %             dx(i)=dx(i)*a;
            %             vy=[vy;x0 y1];
            %         else
            %             dx(i)=dx(i)*b;
            %         end
            %         else
            %             dx(i)=dx(i)*b;
            %         end
            %        end
            %         yn1=myFunc(x0);
            %         if(yn1==yn)
            %             l=l+1;
            %             if(l==N)
            %                    yk=yn1;
            %                    if(sqrt((xk(1)-x0(1))^2+(xk(2)-x0(2))^2+(xk(3)-x0(3))^2)<e1)
            %                        isEndWhile=1;
            %                    else
            %                        xk=x0;
            %                    end
            %                    d=GramSmit(d,lambda);
            %                    lambda=[0 0 0];
            %                    dx=dx0;
            %                    l=0;
            %             else
            %                 if(abs(dx)<e1)
            %                     isEndWhile=1;
            %             end
            %         end
            % end
            % %res=[x0 y];
            % end
            k
            res=vy;
        end
    end
end