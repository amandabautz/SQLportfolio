------------------------------------------------------------------------------------------------------------------
--Data Cleaning in SQL Project
--Data: Nashville Housing Data
------------------------------------------------------------------------------------------------------------------


------------------------------------------------------------------------------------------------------------------
--Standardize Date Format:
SELECT SaleDate, CONVERT(Date, SaleDate)
FROM PortfolioProject.dbo.NashvilleHousing
UPDATE NashvilleHousing
SET SaleDate = CONVERT(Date, SaleDate)
		----Alternatively:
ALTER TABLE NashvilleHousing
Add SaleDateStandard Date; 
UPDATE NashvilleHousing
SET SaleDateStandard = CONVERT(Date, SaleDate)
SELECT SaleDateStandard
FROM PortfolioProject.dbo.NashvilleHousing
------------------------------------------------------------------------------------------------------------------


------------------------------------------------------------------------------------------------------------------
--Populate Missing/NULL Property Address Data
		--Query to find Null Property Address Data
SELECT add1.ParcelID, add1.PropertyAddress, add2.ParcelID, add2.PropertyAddress, ISNULL(add1.PropertyAddress,
		add2.PropertyAddress)
FROM PortfolioProject.dbo.NashvilleHousing add1
JOIN PortfolioProject.dbo.NashvilleHousing add2
	ON add1.ParcelID = add2.ParcelID
	AND add1.UniqueID <> add2.UniqueID
WHERE add1.PropertyAddress is null
		--Update Property Address Data so that it is not null
UPDATE add1
SET PropertyAddress = ISNULL(add1.PropertyAddress, add2.PropertyAddress)
FROM PortfolioProject.dbo.NashvilleHousing add1
JOIN PortfolioProject.dbo.NashvilleHousing add2
	ON add1.ParcelID = add2.ParcelID
	AND add1.UniqueID <> add2.UniqueID
------------------------------------------------------------------------------------------------------------------


------------------------------------------------------------------------------------------------------------------
--Break Out Address Into Individual Columns: Address, City, Sate
		--Add a column for just the split off property address/update the column to include the correct data
ALTER TABLE NashvilleHousing
ADD PropertyAddressSplit NVARCHAR(255);
UPDATE NashvilleHousing
SET PropertyAddressSplit = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 3)
		--Add a column for just the split off property city/update the column to include the correct data
ALTER TABLE NashvilleHousing
ADD PropertyCitySplit NVARCHAR(255);
UPDATE NashvilleHousing
SET PropertyCitySplit = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 2)
		--Add a column for just the split off property state/update the column to include the correct data
ALTER TABLE NashvilleHousing
ADD PropertyStateSplit NVARCHAR(255);
UPDATE NashvilleHousing
SET PropertyStateSplit = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 1)
		--Query the new columns without any null values
SELECT PropertyAddressSplit, PropertyCitySplit, PropertyStateSplit
FROM PortfolioProject.dbo.NashvilleHousing
WHERE PropertyAddressSplit is not null
AND PropertyCitySplit is not null
AND PropertyStateSplit is not null
------------------------------------------------------------------------------------------------------------------


------------------------------------------------------------------------------------------------------------------
--Change Y & N to Yes & No in "Sold As Vacant" Column
UPDATE NashvilleHousing
SET SoldAsVacant = 
CASE WHEN SoldAsVacant = 'Y' THEN 'Yes'
	 WHEN SoldAsVacant = 'N' THEN 'No'
	 ELSE SoldAsVacant
	 END
------------------------------------------------------------------------------------------------------------------


------------------------------------------------------------------------------------------------------------------
--Remove Duplicate Entries With Different UniqueIDs
	--Create a CTE that will create a column called row_num. When row_num > 1, it is a 
	--duplicate entry. These then get deleted.
WITH RowNumCTE AS(
SELECT *,
	ROW_NUMBER() OVER(
	PARTITION BY ParcelID, PropertyAddress, SalePrice, SaleDate, LegalReference
	ORDER BY UniqueID) AS Row_Num
FROM PortfolioProject.dbo.NashvilleHousing
)
DELETE
FROM RowNumCTE
WHERE Row_Num > 1
------------------------------------------------------------------------------------------------------------------


------------------------------------------------------------------------------------------------------------------
--Delete Unnecessary Columns
	--Delete OwnerAddress, PropertyAddress,SaelDate, and SaleDateConverted. These columns are now redundant since
	--new columns were created that include the same and cleaner versions of the same data.
ALTER TABLE PortfolioProject.dbo.NashvilleHousing
DROP COLUMN OwnerAddress, PropertyAddress, SaleDate, SaleDateConverted
------------------------------------------------------------------------------------------------------------------
