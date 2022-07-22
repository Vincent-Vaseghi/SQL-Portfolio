/*
Data Cleaning & Exploration in SQL
*/

-- Explore Data Table and its Columns
SELECT *
FROM Portfolio.dbo.HousingData$


-- Converting DateTime to Date
ALTER TABLE HousingData$
Add SaleDateConverted Date;

UPDATE HousingData$
SET SaleDateConverted = CONVERT(Date,SaleDate)


-- Updating the Null Property Address
SELECT a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, ISNULL(a.PropertyAddress,b.PropertyAddress)
FROM Portfolio.dbo.HousingData$ a
JOIN Portfolio.dbo.HousingData$ b
	ON a.ParcelID = b.ParcelID
	AND a.[UniqueID ] <> b.[UniqueID ]
WHERE a.PropertyAddress is null

UPDATE a
SET PropertyAddress = ISNULL(a.PropertyAddress,b.PropertyAddress)
FROM Portfolio.dbo.HousingData$ a
JOIN Portfolio.dbo.HousingData$ b
	ON a.ParcelID = b.ParcelID
	AND a.[UniqueID ] != b.[UniqueID ]
WHERE a.PropertyAddress is null


-- Splitting PropertyAddress into Separate Columns (Address and City) using SUBSTRING
SELECT
SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1 ) as Address
, SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) + 1 , LEN(PropertyAddress)) as Address
FROM Portfolio.dbo.HousingData$

ALTER TABLE HousingData$
Add PropertySplitAddress Nvarchar(255);

UPDATE HousingData$
SET PropertySplitAddress = SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1 )


ALTER TABLE HousingData$
Add PropertySplitCity Nvarchar(255);

UPDATE HousingData$
SET PropertySplitCity = SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) + 1 , LEN(PropertyAddress))


-- Splitting OwnerAddress into Separate Columns (Address, City, State) using PARSENAME
SELECT
PARSENAME(REPLACE(OwnerAddress, ',', '.') , 3)
,PARSENAME(REPLACE(OwnerAddress, ',', '.') , 2)
,PARSENAME(REPLACE(OwnerAddress, ',', '.') , 1)
FROM Portfolio.dbo.HousingData$

ALTER TABLE HousingData$
Add OwnerSplitAddress Nvarchar(255);

UPDATE HousingData$
SET OwnerSplitAddress = PARSENAME(REPLACE(OwnerAddress, ',', '.') , 3)

ALTER TABLE HousingData$
Add OwnerSplitCity Nvarchar(255);

UPDATE HousingData$
SET OwnerSplitCity = PARSENAME(REPLACE(OwnerAddress, ',', '.') , 2)

ALTER TABLE HousingData$
Add OwnerSplitState Nvarchar(255);

UPDATE HousingData$
SET OwnerSplitState = PARSENAME(REPLACE(OwnerAddress, ',', '.') , 1)


-- Observe values in “SoldAsVacant" column (Y, N, Yes and No)
SELECT DISTINCT(SoldAsVacant), Count(SoldAsVacant)
FROM Portfolio.dbo.HousingData$
GROUP BY SoldAsVacant
ORDER BY 2


-- Change Y and N to Yes and No in "Sold as Vacant" field
SELECT SoldAsVacant
, CASE WHEN SoldAsVacant = 'Y' THEN 'Yes'
	   WHEN SoldAsVacant = 'N' THEN 'No'
	   ELSE SoldAsVacant
	   END
FROM Portfolio.dbo.HousingData$


UPDATE HousingData$
SET SoldAsVacant = CASE WHEN SoldAsVacant = 'Y' THEN 'Yes'
	   WHEN SoldAsVacant = 'N' THEN 'No'
	   ELSE SoldAsVacant
	   END


-- Remove Duplicates
WITH RowNumCTE AS(
SELECT *,
	ROW_NUMBER() OVER (
	PARTITION BY ParcelID,
				 PropertyAddress,
				 SalePrice,
				 SaleDate,
				 LegalReference
				 ORDER BY
					UniqueID
					) row_num

FROM Portfolio.dbo.HousingData$
--ORDER BY ParcelID
)
SELECT *
FROM RowNumCTE
WHERE row_num > 1
ORDER BY PropertyAddress


-- Delete Redundant “TaxDistrict” Columns
ALTER TABLE Portfolio.dbo.HousingData$
DROP COLUMN TaxDistrict
