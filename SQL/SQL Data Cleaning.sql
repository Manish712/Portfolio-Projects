-- The dataset used in this is Nashville Housing Data which can be found in the datasets folder

SELECT * FROM portfolioproject.nashvillehousingdata;

select a.ParcelID,a.PropertyAddress,b.ParcelID,b.PropertyAddress
from portfolioproject.nashvillehousingdata a 
join portfolioproject.nashvillehousingdata b 
on a.ParcelID = b.ParcelID
and a.UniqueID <> b.UniqueID
where a.PropertyAddress is null;

-- in some rows for the parcelID the address was not mentioned so lets check if there is address for same parcelId and If there is then lets update it

select a.ParcelID,a.PropertyAddress,b.ParcelID,b.PropertyAddress,isnull(a.PropertyAddress,b.PropertyAddress)
from portfolioproject.nashvillehousingdata a 
join portfolioproject.nashvillehousingdata b 
on a.ParcelID = b.ParcelID
and a.UniqueID <> b.UniqueID
where a.PropertyAddress is null;

Update portfolioproject.nashvillehousingdata a 
join portfolioproject.nashvillehousingdata b 
on a.ParcelID = b.ParcelID
and a.UniqueID <> b.UniqueID
Set a.PropertyAddress = coalesce(a.PropertyAddress,b.PropertyAddress)
where a.PropertyAddress is null;

-- breaking out address into individual columns (address,city,state)
alter table portfolioproject.nashvillehousingdata
add splitAddress text;

update portfolioproject.nashvillehousingdata
set splitAddress = substring(PropertyAddress,1,position(','in PropertyAddress)-1) ;

alter table portfolioproject.nashvillehousingdata
add splitedCity text;

update portfolioproject.nashvillehousingdata
set splitedCity = substring(PropertyAddress,position(',' in PropertyAddress)+1,length(PropertyAddress));
select 
substring(PropertyAddress,1,position(','in PropertyAddress)-1) as address
,substring(PropertyAddress,position(',' in PropertyAddress)+1,length(PropertyAddress)) as city
from portfolioproject.nashvillehousingdata;

-- the date column is not in the desired format with type as text, so lets change it 
select STR_TO_DATE(SaleDate,'%M %e,%Y') from portfolioproject.nashvillehousingdata;

update portfolioproject.nashvillehousingdata set SaleDate = STR_TO_DATE(SaleDate,'%M %e,%Y');

alter table portfolioproject.nashvillehousingdata modify column SaleDate DATE;

select distinct(SoldAsVacant) from portfolioproject.nashvillehousingdata;

-- converting Y and N to Yes and No in soldAsVacant 

select SoldAsVacant,
case when SoldAsVacant ='Y' then 'Yes'
	 when SoldAsVacant ='N' then'No'
     else SoldAsVacant
end as formattedSoldAsVacant
from portfolioproject.nashvillehousingdata;

-- now checking to see the values in new column
with cte as(
select SoldAsVacant,
case when SoldAsVacant ='Y' then 'Yes'
	 when SoldAsVacant ='N' then'No'
     else SoldAsVacant
end as formattedSoldAsVacant
from portfolioproject.nashvillehousingdata) select distinct(formattedSoldAsVacant) from cte;  

-- now let's update
Update   portfolioproject.nashvillehousingdata
set SoldAsVacant = case when SoldAsVacant ='Y' then 'Yes'
	 when SoldAsVacant ='N' then'No'
     else SoldAsVacant
end;

-- removing duplicates
with rownumcte as(
select * , row_number() over( partition by ParcelID,PropertyAddress,SaleDate,SalePrice,LegalReference order by UniqueId) as row_num
from portfolioproject.nashvillehousingdata
)
select * from rownumcte where row_num>1;

with rownumcte as(
select * , row_number() over( partition by ParcelID,PropertyAddress,SaleDate,SalePrice,LegalReference order by UniqueId) as row_num
from portfolioproject.nashvillehousingdata
)
delete from rownumcte where row_num>1;


