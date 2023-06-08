--Cleaning data in SQL

select * from Portfolio..NashvilleHousing


--------------------------------------------------------------------------------

--1 Standardize Date Format
select SaleDateConverted from Portfolio..NashvilleHousing

--update NashvilleHousing
--set SaleDate = CONVERT(Date,SaleDate)
--with this data is not updating

alter table NashvilleHousing
add SaleDateConverted Date

update NashvilleHousing
set SaleDateConverted = CONVERT(Date,SaleDate)
--with this data is updated


--------------------------------------------------------------------------------

--2 Populate Property Address Data
select * from Portfolio..NashvilleHousing
order by ParcelID
where PropertyAddress is null

--case: they have the same ParcelID. Same ParcelID = PropertyAddress
-- so we populate the data from the same ParcelID
select a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress,
	ISNULL(a.PropertyAddress, b.PropertyAddress)
from Portfolio..NashvilleHousing a
join Portfolio..NashvilleHousing b
	on a.ParcelID = b.ParcelID
	AND a.UniqueID <> b.UniqueID
where a.PropertyAddress is null

update a
set PropertyAddress = ISNULL(a.PropertyAddress, b.PropertyAddress)
from Portfolio..NashvilleHousing a
join Portfolio..NashvilleHousing b
	on a.ParcelID = b.ParcelID
	AND a.UniqueID <> b.UniqueID

--------------------------------------------------------------------------------

--3 Breaking out address into individual columns (address city state)
select * from Portfolio..NashvilleHousing

select SUBSTRING(PropertyAddress,1,CHARINDEX(',', PropertyAddress)-1) as Address,
SUBSTRING(PropertyAddress,CHARINDEX(',', PropertyAddress)+1, LEN(PropertyAddress)) as City
from NashvilleHousing

alter table NashvilleHousing
add Address nvarchar(255)

update NashvilleHousing
set Address = SUBSTRING(PropertyAddress,1,CHARINDEX(',', PropertyAddress)-1)

alter table NashvilleHousing
add City nvarchar(255)

update NashvilleHousing
set City = SUBSTRING(PropertyAddress,CHARINDEX(',', PropertyAddress)+1, LEN(PropertyAddress))

select 
PARSENAME(REPLACE(OwnerAddress,',','.'),3),
PARSENAME(REPLACE(OwnerAddress,',','.'),2),
PARSENAME(REPLACE(OwnerAddress,',','.'),1)
from NashvilleHousing
where OwnerAddress is not null
--Parsename works backward
--parsename also works only with '.' therefore we use replace to replace comma with dot

select * from NashvilleHousing where OwnerAddress is not null

alter table NashvilleHousing
add Owner_Address nvarchar(255)

alter table NashvilleHousing
add Owner_City nvarchar(255)

alter table NashvilleHousing
add Owner_State nvarchar(255)

update NashvilleHousing
set Owner_Address = PARSENAME(REPLACE(OwnerAddress,',','.'),3),
Owner_City = PARSENAME(REPLACE(OwnerAddress,',','.'),2),
Owner_State = PARSENAME(REPLACE(OwnerAddress,',','.'),1)

--------------------------------------------------------------------------------

--4 Change Y and N to Yes or No in 'Sold as Vacant' field
select distinct SoldAsVacant
--CASE WHEN SoldAsVacant = 'Y' then 'Yes'
--	 WHEN SoldAsVacant = 'N' then 'No'
--	 ELSE SoldAsVacant
--	 END
from NashvilleHousing

update NashvilleHousing
set SoldAsVacant = 
CASE WHEN SoldAsVacant = 'Y' then 'Yes'
	 WHEN SoldAsVacant = 'N' then 'No'
	 ELSE SoldAsVacant
	 END
from NashvilleHousing

--------------------------------------------------------------------------------

--5 Remove duplication
;WITH ROWNUMCTE 
as (
select *,
	ROW_NUMBER() OVER (
	PARTITION BY PARCELID,
				 PropertyAddress,
				 SalePrice,
				 SaleDate,
				 LegalReference
				 ORDER BY 
					UniqueID) row_num
from NashvilleHousing
)
--delete from ROWNUMCTE
select * from ROWNUMCTE
where row_num > 1

select legalreference, count(legalreference) from NashvilleHousing
group by legalreference

--------------------------------------------------------------------------------

--6 Delete unused columns
alter table NashvilleHousing
drop column OwnerAddress,SaleDate,PropertyAddress,TaxDistrict

select * from NashvilleHousing
