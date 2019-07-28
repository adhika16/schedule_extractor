clear; clc; close all;
% read input data 
fileName = 'schedule.csv';
C = readtable(fileName, 'Delimiter',',', 'FileEncoding', 'UTF-8');
[nrow,ncol] = size(C);
% assigning values
a_time = C.Waktu;
a_origin = C.Asal;
a_airline = C.Maskapai;
a_flight = C.Penerbangan;
a_terminal = C.Terminal_Pintu;
a_etc = C.Keterangan;
a_baggage = C.Bagasi;
a_radar = C.Radar_Penerbangan;
% code variables
a_origin_code = cell(nrow,1);
a_airline_code = cell(nrow,1);
for i = 1:nrow
    tempString1 = char(a_time(i,1)); % sectioning time
    tempString2 = char(a_origin(i,1)); % sectioning origin
    tempString3 = char(a_airline(i,1)); % sectioning airline
    
    a_time(i,1) = cellstr(tempString1(1:5)); 
    
    a_origin_code(i,1) = cellstr(tempString2(1:3)); 
    a_origin(i,1) = cellstr(tempString2(5:end));

    a_airline_code(i,1) = cellstr(tempString3(1:2));
    a_airline(i,1) = cellstr(tempString3(4:end));
end

a_airline_code_data = unique(a_airline_code);
n_airline = size(a_airline_code_data); 

schedule_date = datetime(2019,7,26);
hour_bound = linspace(0,23,24);
min_lbound = [0 15 30 45];
min_ubound = [14 29 44 59];

n_time_range = length(hour_bound)*length(min_lbound);
time_range = zeros(n_time_range, n_airline(1));

time_ubound = datetime(2019*ones(n_time_range,1),7,26,0,0,0);
time_lbound = datetime(2019*ones(n_time_range,1),7,26,0,0,0);
count = 1; % temp value

for i = 1:length(hour_bound) % hour
    for j = 1:length(min_lbound) % min
        time_lbound(count) = schedule_date + hours(hour_bound(i)) + minutes(min_lbound(j));
        time_ubound(count) = schedule_date + hours(hour_bound(i)) + minutes(min_ubound(j));
        count = count + 1;
    end
end

for i = 1:nrow
    tempTime = datetime(char(a_time(i)), 'InputFormat', 'HH:mm', 'Format', 'HH:mm:ss');
    [h,m] = hms(tempTime);
    i
    for j = 1:n_time_range
        [hl,ml] = hms(time_lbound(j));
        [hu,mu] = hms(time_ubound(j));
        if( h==hl && (m>=ml && m<=mu) )
            for k = 1:n_airline
                if( char(a_airline_code(i)) == char(a_airline_code_data(k)) )
                    time_range(j,k) = time_range(j,k) + 1;
                end
            end
        end
    end
end

data_count = cell(n_time_range, n_airline(1));
data_col_lbound = cell(n_time_range, 1);
data_col_ubound = cell(n_time_range, 1);
data_header_count = cell(1,n_airline(1));

for i = 1:n_time_range
    data_col_lbound(i) = cellstr(time_lbound(i));
    data_col_ubound(i) = cellstr(time_ubound(i));
end

data_header_1 = cellstr('lowerbound');
data_header_2 = cellstr('upperbound');
for i = 1:n_airline(1)
    data_header_count(1,i) = a_airline_code_data(i);
end

for i = 1:n_time_range
    for j = 1:n_airline(1)
        data_count(i,j) = cellstr(num2str(time_range(i,j)));
    end
end

% save output into .csv file
T = table(data_col_lbound, data_col_ubound, data_count);
% data_header = table(data_header_1, data_header_2, data_header_count);
% T.Properties.VariableNames = data_header;
writetable(T,'out.csv','Delimiter',',');