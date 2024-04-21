Select *
From Nashville

------- Standardize date format
Select SaleDate
From Nashville

Select SaleDateConverted, CONVERT(Date,SaleDate)
From Nashville

Update Nashville
Set SaleDate = CONVERT(Date,SaleDate)

Alter Table Nashville
Add SaleDateConverted Date;

Update Nashville
Set SaleDateConverted = CONVERT(Date,SaleDate)




------- Filling the Blank PropertyAddress Spaces

Select PropertyAddress
From Nashville

Select PropertyAddress
From Nashville
Where PropertyAddress is null

Select *
From Nashville
--Where PropertyAddress is null
Order by ParcelID


Select a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, ISNULL(a.PropertyAddress,b.PropertyAddress)
From Nashville as a
Join Nashville as b
	On a.ParcelID = b.ParcelID
	And a.[UniqueID ] <> b.[UniqueID ]
Where a.PropertyAddress is null


Update a
SET PropertyAddress = ISNULL(a.PropertyAddress,b.PropertyAddress)
From Nashville as a
Join Nashville as b
On a.ParcelID = b.ParcelID
And a.[UniqueID ] <> b.[UniqueID ]
Where a.PropertyAddress is null


--Breaking Out PropertyAddress Into Individual Columns (Address & City)

Select PropertyAddress
From Nashville


Select
SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1) as Address,
SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) +1, LEN(PropertyAddress)) as City
From Nashville

Alter Table Nashville
Add Property_Address Nvarchar(255);

Update Nashville
Set Property_Address = SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1)


Alter Table Nashville
Add Property_City Nvarchar(255);

Update Nashville
Set Property_City = SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) +1, LEN(PropertyAddress))

Select *
From Nashville

Select Property_address, property_city
From Nashville


--Breaking Out OwnerAddress Into Individual Columns (Address, City & State)

Select OwnerAddress
From Nashville

Select
PARSENAME(Replace(OwnerAddress, ',','.') ,3),
PARSENAME(Replace(OwnerAddress, ',','.') ,2),
PARSENAME(Replace(OwnerAddress, ',','.') ,1)
from Nashville


Alter Table Nashville
Add Owner_Address Nvarchar(255);

Update Nashville
Set Owner_Address = PARSENAME(Replace(OwnerAddress, ',','.') ,3)

Alter Table Nashville
Add Owner_City Nvarchar(255);

Update Nashville
Set Owner_City = PARSENAME(Replace(OwnerAddress, ',','.') ,2)

Alter Table Nashville
Add Owner_State Nvarchar(255);

Update Nashville
Set Owner_State = PARSENAME(Replace(OwnerAddress, ',','.') ,1)

Select *
From Nashville


--Change Y and N to Yes and No in "Sold as Vacant" field

Select SoldAsVacant
From Nashville


Select Distinct(SoldAsVacant), count(soldasvacant)
From Nashville
Group by SoldAsVacant
Order by 2

Select SoldAsVacant,
Case
	When SoldAsVacant = 'Y' then 'Yes'
	When SoldAsVacant = 'N' then 'No'
	Else SoldAsVacant
End
From Nashville

Update Nashville
SET SoldAsVacant = Case
	When SoldAsVacant = 'Y' then 'Yes'
	When SoldAsVacant = 'N' then 'No'
	Else SoldAsVacant
End



--Remove duplicates

WITH RowNumCTE As(
Select *,
	ROW_NUMBER() OVER (
	Partition By ParcelID, 
				PropertyAddress,
				SalePrice,
				SaleDate,
				LegalReference
				Order by
					UniqueID
					) Row_Num

From Nashville
)
delete 
From RowNumCTE
Where Row_Num > 1
--Order by PropertyAddress


WITH RowNumCTE As(
Select *,
	ROW_NUMBER() OVER (
	Partition By ParcelID, 
				PropertyAddress,
				SalePrice,
				SaleDate,
				LegalReference
				Order by
					UniqueID
					) Row_Num

From Nashville
)
Select * 
From RowNumCTE
Where Row_Num > 1
Order by PropertyAddress



--Delete Unused Columns


Select *
From Nashville

Alter Table Nashville
Drop Column OwnerAddress, PropertyAddress, SaleDate, TaxDistrict 


