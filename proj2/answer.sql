set serveroutput on size 32000

Question 1: CarRentalSiteDetail detail
create or replace procedure CarRentalSiteDetail (id IN CarRentalSite.CarRentalSiteId%TYPE) as

rental_name CarRentalSite.CarRentalSiteName%TYPE;
rental_city CarRentalSite.City%TYPE;
rental_count number;
pop varchar(30);
longest_rental integer;
CURSOR enr_cur is Select CarRentalSiteName, City from CarRentalSite where CarRentalSiteId = id;
ren_rec ren_cur%ROWTYPE;
CURSOR car_cur is Select CarId, CarName, Category from Car;
car_rec car_cur%ROWTYPE;

BEGIN

rental_count := 0;
longest_rental := 0;

for enr_rec in enr_cur loop
        rental_city := enr_rec.City;
        rental_name := enr_rec.CarRentalSiteName;
end loop;

for ren_rec in rec_cur loop
        rental_count := rental_count + 1;
        for car_rec in car_cur loop
                if ren_rec.CarId = car_rec.CarId then
                        if car_rec.Category = 'compact' then
                                pop := car_rec.CarName;
                                longest_rental := ren_rec.numOfDays;
                        end if;
                end if;
        end loop;
end loop;

END CarRentalSiteDetail;
/

BEGIN
CarRentalSiteDetail(1);
end;
/


-- Question 2:

create or replace procedure MonthlyBusinessRentalsReport as

CURSOR site_cur is Select CarRentalSiteId, CarRentalSiteName from CarRentalSite 
order by CarRentalSiteName;
site_rec site_cur%ROWTYPE;

CURSOR ren_cur is Select extract(year from RentalDate) as yy, extract(month from RentalDate) as mm, count(CarRentalSiteId) as num from Rentals 
where Status = 'BUSINESS'
group by extract(year from RentalDate), extract(month from RentalDate) 
order by yy, mm;
ren_rec ren_cur%ROWTYPE;

CURSOR rental_cur is Select CarRentalSiteId, numOfDays, extract(year from RentalDate) as y, extract(month from RentalDate) as m from Rentals
where Status = 'BUSINESS';
rental_rec rental_cur%ROWTYPE;

month integer;
year integer;
day integer;
business integer;
siteId integer;
siteName varchar(255);

BEGIN

for ren_rec in ren_cur loop
        month := ren_rec.mm;
        year := ren_rec.yy;
        day := ren_rec.count;

        dbms_output.put_line('Total Business Rentals in ' || year || '-' || month || ': ' || day);
        dbms_output.put_line('In Car Rental Sites: ');

        for site_rec in site_cur loop
                siteId := site_rec.CarRentalSiteId;
                siteName := site_rec.CarRentalSiteName;
                business := 0;
                for rental_rec in rental_cur loop
                        if rental_rec.CarRentalSiteId = siteId then
                                if rental_rec.y = year then
                                        if rental_rec.m = month then
                                                business := business + rental_rec.numOfDays;
                                        end if;
                                end if;
                        end if;
                end loop;
                if business != 0 then
                        dbms_output.put_line('- ' || siteName || ': ' || business || ' days');
                end if;
        end loop;
end loop;

END MonthlyBusinessRentalsReport;
/

BEGIN
        MonthlyBusinessRentalsReport;
End;
/


-- Question 3:

create or replace procedure MostandLeastProfitCarIndiana as

cars number;
cars_count number;
avg_profit number;
category varchar(255);
min_profit number;
max_profit number;
min_name varchar(255);
max_name varchar(255);

temp number;
avg_temp number;

CURSOR cart_cur is Select Car.CarId, Car.CarName, Car.Category, Car.SuggestedDealerRentalPrice from CarDealers 
join Car on CarDealers.DealerId = Car.DealerId
where CarDealers.State = 'IN'
order by Car.Category, Car.CarName asc;
cart_rec cart_cur%ROWTYPE;

CURSOR ren_cur is Select CarId, RentalRate from Rentals;
ren_rec ren_cur%ROWTYPE;

CURSOR car_cur is Select Car.CarId, Car.CarName, Car.Category, Car.DealerId, Car.SuggestedDealerRentalPrice, CarDealers.State from CarDealers
join Car on CarDealers.DealerId = Car.DealerId
where CarDealers.State = 'IN'
Order by Car.Category, Car.CarName asc;
car_rec car_cur%ROWTYPE;

BEGIN

category = '';
min_profit := 10000;
max_profit := 0;

for car_rec in car_cur loop
        cars_count := 0;
        avg_profit := 0;

        if category != '' and category != car_rec.Category then
                dbms_output.put_line('Least Profit in ' || Category);
                for cart_rec in cart_cur loop
                        num_temp := 0;
                        avg_temp := 0;
                        if category = cart_rec.Category then
                                for ren_rec in ren_cur loop
                                        if cart_rec.CarId = ren_rec.CarId then
                                                num_temp := num_temp + 1;
                                                avg_temp := avg_temp + (ren_rec.RentalRate - cart_rec.SuggestedDealerRentalPrice);
                                        end if;
                                end loop;
                                avg_temp := avg_temp / num_temp;
                                if min_profit = avg_temp then
                                        min_name := cart_rec.CarName;
                                        dbms_output.put_line('- ' || min_name || ': ' || avg_temp);
                                end if;
                        end if;
                end loop;
                min_profit := 10000;
        end if;
        
        for ren_rec in ren_cur loop
                if car_rec.CarId = ren_rec.CarId then
                        cars_count := cars_count + 1;
                        avg_profit := avg_profit + (ren_rec.RentalRate - car_rec.SuggestedDealerRentalPrice);
                end if;
        end loop;

        avg_profit := avg_profit/cars_count;
        if min_profit > avg_profit then
                min_profit := avg_profit;
        end if;
        category := car_rec.Category;
end loop;

dbms_output.put_line('Least Profit in ' || Category);

for cart_rec in cart_cur loop
        num_temp := 0;
        avg_temp := 0;
        if category = cart_rec.Category then
                for ren_rec in ren_cur loop
                        if cart_rec.CarId = ren_rec.CarId then
                                num_temp := num_temp + 1;
                                avg_temp := avg_temp + (ren_rec.RentalRate - cart_rec.SuggestedDealerRentalPrice);
                        end if;
                end loop;
                avg_temp := avg_temp / num_temp;

                if min_profit = avg_temp then
                        min_name := cart_rec.CarName;
                        dbms_output.put_line('- ' || min_name || ': ' || avg_temp);
                end if;
        end if;
end loop;

category := '';

for car_rec in car_cur loop
        cars_count := 0;
        avg_profit := 0;
        if category != '' and car_rec.Category != category then
                dbms_output.put_line('Most Profit in ' || Category);
                for cart_rec in cart_cur loop
                        num_temp := 0;
                        avg_temp := 0;
                        if category = cart_rec.Category then
                                for ren_rec in ren_cur loop
                                        if cart_rec.CarId = ren_rec.CarId then
						num_temp := num_temp + 1;
                                                avg_temp := avg_temp + (ren_rec.RentalRate - cart_rec.SuggestedDealerRentalPrice);
                                        end if;
                                end loop;
					
                                avg_temp := avg_temp/num_temp;
				if max_profit = avg_temp then
					max_name := cart_rec.CarName;		
					dbms_output.put_line('- ' || max_name || ': ' || avg_temp);
				end if;
			end if;
                end loop;
                max_profit := 0;
        end if;

        for ren_rec in ren_cur loop
		if car_rec.CarId = ren_rec.CarId then
                        cars_count := cars_count + 1;
			avg_profit := avg_profit + (ren_rec.RentalRate - car_rec.SuggestedDealerRentalPrice);
		end IF;
	end loop;
		
        avg_profit := avg_profit / cars_count;		
		if max_profit < avg_profit then
                        max_name := car_rec.CarName;
			max_profit := avg_profit;
		end if;
		category := car_rec.Category;
	end loop;

        dbms_output.put_line('Most Profit in ' || Category);
	
        for cart_rec in cart_cur loop
		num_temp := 0;
                avg_temp := 0;
		if category = cart_rec.Category then
			for ren_rec in ren_cur loop
				if cart_rec.CarId = ren_rec.CarId then
                                        num_temp := num_temp + 1;
					avg_temp := avg_temp + (ren_rec.RentalRate - cart_rec.SuggestedDealerRentalPrice);
				end if;
			end loop;
			avg_temp := avg_temp / num_temp;
			if max_profit = avg_temp then
				max_name := cart_rec.CarName;
				dbms_output.put_line('- ' || max_name || ': ' || avg_temp);
			end if;
		end if;
	end loop;

END MostandLeastProfitCarIndiana;
/

BEGIN
        MostandLeastProfitCarIndiana;
END;
/


-- Question 4:

create table BusinessRentalCategoryTable(CarRentalSiteId integer, Compact integer, Luxury integer, SUV integer, primary key(CarRentalSiteId));
create or replace procedure BusinessRentalCategory as

compact_count integer;
suv_count integer;
luxury_count integer;
site_id integer;
site_num integer;

CURSOR car_cur is Select CarId, Category from Car;
car_rec car_cur%ROWTYPE;
CURSOR site_cur is Select CarRentalSiteId from CarRentalSite;
site_rec site_cur%ROWTYPE;
CURSOR ren_cur is Select CarId, CarRentalSiteId, Status from Rentals where Status = 'BUSINESS';
ren_rec ren_cur%ROWTYPE;

BEGIN

site_id := 1;

for site_rec in site_cur loop
        compact_count := 0;
        suv_count := 0;
        luxury_count := 0;
        for ren_rec in ren_cur loop
                if site_id = ren_rec.CarRentalSiteId then
                        for car_rec in car_cur loop
                                if car_rec.CarId = ren_rec.CarId then
                                        if car_rec.Category = 'compact' then
                                                compact_count := compact_count + 1;
                                        end if;
                                        if car_rec.Category = 'SUV' then
                                                suv_count := suv_count + 1;
                                        end if;
                                        if car_rec.Category = 'luxury' then
                                                luxury_count := luxury_count + 1;
                                        end if;
                                end if;
                        end loop;
                end if;
        end loop;

        insert into BusinessRentalCategoryTable values (site_id, compact_count, luxury_count, suv_count);
        site_id := site_id + 1;
end loop;

END BusinessRentalCategory;
/

BEGIN
BusinessRentalCategory;
END;
/
select * from BusinessRentalCategoryTable;

drop table BusinessRentalCategoryTable;


-- Question 5:

create or replace procedure CarCategoryInventoryInfo(crsid in CarRentalSite.CarRentalSiteId%TYPE) as

CURSOR inv_cur is Select CarRentalSiteId, CarId, TotalCars from RentalInventories;
inv_rec inv_cur%ROWTYPE;

CURSOR enr_cur is Select CarRentalSiteName, City, CarRentalSiteId from CarRentalSite 
where CarRentalSiteId = crsid
order by CarRentalSiteName asc;
enr_rec enr_cur%ROWTYPE;

CURSOR exe_cur is Select CarRentalSiteId from CarRentalSite where CarRentalSiteId = crsid;

CURSOR ren_cur is Select distinct Car.CarId, Car.CarName, Rentals.CarRentalSiteId 
from Car join Rentals on Rentals.CarId = Car.CarId 
order by Car.CarName asc;
ren_rec ren_cur%ROWTYPE;

car_num integer;
car_name varchar(255);
site_name varchar(255);
site_id integer;

sb exception;

BEGIN

dbms_output.put_line('CarRentalSiteId: ' || crsid);
open exe_cur;
fetch exe_cur into site_id;
if exe_cur%notfound then
        raise sb;
end if;

for enr_rec in enr_cur loop
        siteName := enr_rec.CarRentalSiteName;
        dbms_output.put_line('CarRentalSiteName: ' || site_name);
        for ren_rec in ren_cur loop
                if ren_rec.CarRentalSiteId = enr_rec.CarRentalSiteId then
                        car_name := ren_rec.CarName;
                        for inv_rec in inv_cur loop
                                if ren_rec.CarId = inv_rec.CarId then
                                        if ren_rec.CarRentalSiteId = inv_rec.CarRentalSiteId then
                                                car_num := inv_rec.TotalCars;
                                        end if;
                                end if;
                        end loop;
                        dbms_output.put_line('CarName: ' || car_name || ': ' || car_num);
                end if;
        end loop;
end loop;

exception
        when sb then
                dbms_output.put_line('Invalid CarRentalSiteId!');

END CarCategoryInventoryInfo;
/

BEGIN
CarCategoryInventoryInfo(1);
END;
/

BEGIN
CarCategoryInventoryInfo(111);
END;
/

