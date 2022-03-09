function [ date_str ] = get_date_str( )
% outputs todays date in a string: 'yyyymmdd'

date_info = datevec(date);

year_num = date_info(1);
month_num = date_info(2);
day_num = date_info(3);

year_str = num2str(year_num);

if (month_num<10)
    month_str = strcat( '0', num2str(month_num) );
else
    month_str = num2str(month_num);
end

if (day_num<10)
    day_str = strcat( '0', num2str(day_num) );
else
    day_str = num2str(day_num);
end

date_str = strcat(year_str, month_str, day_str );

end

