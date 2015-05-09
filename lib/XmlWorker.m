classdef XmlWorker
    %XMLWORKER Encapsulate logic work with xml
    %   Execute reading/writing of parameters

    
    properties
        document;
        path;
    end
    
    methods(Access = private)
        function setParameters(this, list, values)
            quantity = list.getLength;
            if ( quantity ~= max(size(values)) )
                error('\"values\" must have same size as parameters quantity.');
            end
            for i = 0 : quantity - 1
                list.item(i).getFirstChild.setData(num2str(values(i + 1)));
            end
            this.write();
        end
        function [values, names] = getParameters(this, list)
            quantity = list.getLength;
            values = zeros(quantity, 1);
            names = cell(quantity, 1);
            for i = 0 : quantity - 1
                item = list.item(i);
                values(i + 1) = str2double(item.getFirstChild.getData);
                names(i + 1) = cellstr(char(item.getAttribute('name')));                
            end 
        end
        function [values, names, min, max, step] = getInput(this)
            list = this.document.getElementsByTagName('input').item(0)...
                                .getElementsByTagName('parameter');
            quantity = list.getLength;            
            min = zeros(quantity, 1);
            max = zeros(quantity, 1);
            step = zeros(quantity, 1);
            for i = 0 : quantity - 1
                item = list.item(i);                
                min(i + 1) = str2double(item.getAttribute('min'));
                max(i + 1) = str2double(item.getAttribute('max'));               
                step(i + 1) = str2double(item.getAttribute('step'));
            end            
            [values, names] = this.getParameters(list);
        end
        function write(this)
            xmlwrite(this.path, this.document);
            this.xmlRemoveExtraLines();
        end
        function xmlRemoveExtraLines(this)
            fId = fopen(this.path, 'r');
            fileContents = fread(fId, '*char')';
            fclose(fId);
            fId = fopen(this.path, 'w');
            fwrite(fId, regexprep(fileContents, '\n\s*\n', '\n'));
            fclose(fId);
        end
    end
    
    methods (Access = public)
        function [this] = XmlWorker(path)
            this.path = path;
            this.document = xmlread(path);
        end
        function [inValues, inNames] = getInputParameters(this)
            this.document = xmlread(this.path);            
            [inValues, inNames] = this.getInput();
        end
        function setInputParameters(this, inVector)
            list = this.document.getElementsByTagName('input').item(0)...
                                .getElementsByTagName('parameter');
            this.setParameters(list, inVector);
        end
        function [outValues, outNames] = getOutputParameters(this)
            this.document = xmlread(this.path);
            list = this.document.getElementsByTagName('output').item(0)...
                                .getElementsByTagName('parameter');
            [outValues, outNames] = this.getParameters(list);
        end        
        function bounds = getInputBounds(this)
            this.document = xmlread(this.path);
            [~, ~, min, max, ~] = this.getInput();
            bounds = [min, max];      
        end
        function steps = getSteps(this)
            [~, ~, ~, ~, steps] = this.getInput();
        end
        function value = getValueOf(this, tagName)
            value = this.document.getElementsByTagName(tagName).item(0).getFirstChild.getData;
        end
    end
end

