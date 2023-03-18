
--/* 

--Cleaning data using SQL


--*/


Select * from [dbo].[Nashville_housing]


--**********************************************************************************************************************************************************************

-- Checking the date format
Begin Tran
	
Begin try

Select SaleDate from [dbo].[Nashville_housing]  --all the rows Has timestamp 00. Hence removing

ALTER TABLE [dbo].[Nashville_housing]  --Converting the data type from datetime to time
ALTER COLUMN SaleDate date;

Select SaleDate from [dbo].[Nashville_housing]  


End try

Begin Catch

rollback transaction

End catch

--commit transaction



--**********************************************************************************************************************************************************************

-- Data set has duplicate values hence using Distinct 
--Property address has Null values. As per analysis, Parcel ID and propertyAddress are tied together.

Begin Tran
	
Begin try

Select DISTINCT a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, ISNULL(a.PropertyAddress, b.PropertyAddress)
from Nashville_housing a JOIN Nashville_housing b on a.ParcelID = b.ParcelID and a.[UniqueID ] <> b.[UniqueID ]
Where a.PropertyAddress IS NULL

Update a
SET PropertyAddress = ISNULL(a.PropertyAddress, b.PropertyAddress)
from Nashville_housing a JOIN Nashville_housing b on a.ParcelID = b.ParcelID and a.[UniqueID ] <> b.[UniqueID ]
Where a.PropertyAddress IS NULL

Select DISTINCT * from [dbo].[Nashville_housing] Order by ParcelID



End try

Begin Catch

rollback transaction

End catch

--commit transaction

--**********************************************************************************************************************************************************************

--Splitting Address

-- property address into individual columns (Address, State, City)

Select PropertyAddress from [dbo].[Nashville_housing]  


select substring(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1) AS Address,
substring(PropertyAddress, CHARINDEX(',', PropertyAddress)+1, LEN(PropertyAddress)) AS Address
from [dbo].[Nashville_housing]  


ALTER TABLE [dbo].[Nashville_housing]  
add PropertySplitAddress NVARCHAR(255);

ALTER TABLE [dbo].[Nashville_housing]  
add PropertySplitcity NVARCHAR(255);

Update [dbo].[Nashville_housing]  
set PropertySplitAddress = substring(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1) 


Update [dbo].[Nashville_housing]  
set PropertySplitcity = substring(PropertyAddress, CHARINDEX(',', PropertyAddress)+1, LEN(PropertyAddress)) 


Select * from [dbo].[Nashville_housing]


-----------------------------------------------------------------------------------------------------------------------------------------

-- owner address into individual columns (Address, State, City)


Select Parsename (replace(OwnerAddress, ',','.'), 3) ,
Parsename (replace(OwnerAddress, ',','.'), 2) ,
Parsename (replace(OwnerAddress, ',','.'), 1) 
from [dbo].[Nashville_housing]

ALTER TABLE [dbo].[Nashville_housing]  
add OwnerSplitAddress NVARCHAR(255);


ALTER TABLE [dbo].[Nashville_housing]  
add OwnerSplitcity NVARCHAR(255);

ALTER TABLE [dbo].[Nashville_housing]  
add OwnerSplitstate NVARCHAR(255);



Update [dbo].[Nashville_housing]  
set OwnerSplitAddress = Parsename (replace(OwnerAddress, ',','.'), 3)

Update [dbo].[Nashville_housing]  
set OwnerSplitcity = Parsename (replace(OwnerAddress, ',','.'), 2) 

Update [dbo].[Nashville_housing]  
set OwnerSplitstate = Parsename (replace(OwnerAddress, ',','.'), 1) 


Select * from [dbo].[Nashville_housing]


--**********************************************************************************************************************************************************************

--Change Y and N to Yes and No in Sold As Vacant column
Select DISTINCT (SoldAsVacant), count(SoldAsVacant)
from [dbo].[Nashville_housing] 
Group by SoldAsVacant
order by 2

Select SoldAsVacant,
Case when SoldAsVacant = 'Y' then 'Yes'
	 when SoldAsVacant = 'N' then 'No'
	 Else SoldAsVacant
	 END
from [dbo].[Nashville_housing]

Update Nashville_housing
Set SoldAsVacant = Case when SoldAsVacant = 'Y' then 'Yes'
	 when SoldAsVacant = 'N' then 'No'
	 Else SoldAsVacant
	 END


Select DISTINCT (SoldAsVacant), count(SoldAsVacant)
from [dbo].[Nashville_housing] 
Group by SoldAsVacant
order by 2


**********************************************************************************************************************************************************************


--Remove Duplicates

--Deleting the 2nd rows which are duplicate


With RowNumCTE AS (
select * ,
ROW_NUMBER() OVER (
PARTITION BY ParcelID,
PropertyAddress,
SalePrice,
SaleDate,
LegalReference
Order BY
	UniqueID
	) row_num

from Nashville_housing

)
Select * from RowNumCTE

Delete from RowNumCTE
where row_num > 1


--******************************************************************************************************************************************************************************


--Deleting unused columns since it has been split to different columns

Select * from [dbo].[Nashville_housing]

Alter table [dbo].[Nashville_housing]
Drop column OwnerAddress, PropertyAddress

Select * from [dbo].[Nashville_housing]


--******************************************************************************************************************************************************************************












