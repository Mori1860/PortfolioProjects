SELECT *
from NashvilleHousing

-- 1 --Standardiza date format
SELECT SaleDate, CONVERT(date, Saledate)
From NashvilleHousing

-- update date column
UPDATE NashvilleHousing
    SET SaleDate = CONVERT(date, Saledate)

-- Add new colomn 
ALTER TABLE NashvilleHousing
ADD SaleDateConverted Date

-- 2 -- Populate PropertyAddress data
SELECT *
FROM NashvilleHousing
WHERE PropertyAddress is NULL

-- detecting NULL missing data
SELECT a.ParcelID, a.PropertyAddress , b.ParcelID , b.PropertyAddress , ISNULL(a.PropertyAddress, b.PropertyAddress)
from NashvilleHousing a
JOIN NashvilleHousing b
    on a.ParcelID = b.ParcelID
    AND a.UniqueID <> b.UniqueID
WHERE a.PropertyAddress is null    

-- populating data
update a
SET PropertyAddress = ISNULL(a.PropertyAddress, b.PropertyAddress)
from NashvilleHousing a
JOIN NashvilleHousing b
    on a.ParcelID = b.ParcelID
    AND a.UniqueID <> b.UniqueID
WHERE a.PropertyAddress is null  


SELECT *
FROM NashvilleHousing
-- 3 -- Breaking out Address into individual colomns(Address, City, State)

-- using Substring
SELECT 
SUBSTRING( PropertyAddress, 1, CHARINDEX(',' , PropertyAddress) - 1) as PropertyAddress
, SUBSTRING(PropertyAddress, CHARINDEX(',' , PropertyAddress) + 1 , LEN(PropertyAddress)) as PropertyCity
FROM NashvilleHousing

ALTER table NashvilleHousing
Add Property_Address NVARCHAR(255)

UPDATE NashvilleHousing
    SET PropertyAddress = SUBSTRING( PropertyAddress, 1, CHARINDEX(',' , PropertyAddress) - 1)

ALTER table NashvilleHousing
ADD PropertyCity NVARCHAR(255)

UPDATE NashvilleHousing
    SET PropertyCity = SUBSTRING(PropertyAddress, CHARINDEX(',' , PropertyAddress) + 1 , LEN(PropertyAddress))

SELECT *
FROM NashvilleHousing


-- using ParseName
SELECT
PARSENAME(REPLACE( OwnerAddress, ',' , '.'), 3)
FROM NashvilleHousing

ALTER TABLE NashvilleHousing
ADD Owner_Address NVARCHAR(255)

ALTER TABLE NashvilleHousing
ADD Owner_City NVARCHAR(255)

ALTER TABLE NashvilleHousing
ADD Owner_State NVARCHAR(50)

UPDATE NashvilleHousing
    SET Owner_Address = PARSENAME(REPLACE( OwnerAddress, ',' , '.'), 3)

UPDATE NashvilleHousing
    SET Owner_City = PARSENAME(REPLACE( OwnerAddress, ',' , '.'), 2)

UPDATE NashvilleHousing
    SET Owner_State = PARSENAME(REPLACE( OwnerAddress, ',' , '.'), 1)

SELECT *
FROM NashvilleHousing


-- 4 -- Change Y and N to Yes and No in 'SoldAsVacant' field

-- Detecting variety of values in the column
SELECT 
DISTINCT(SoldAsVacant) 
FROM NashvilleHousing

-- Replace values of Y and N to Yes and No
SELECT SoldAsVacant,
CASE 
    WHEN SoldAsVacant = 'Y' THEN 'Yes'
    WHEN SoldAsVacant = 'N' then 'No'
    ELSE SoldAsVacant
END  
FROM NashvilleHousing

UPDATE NashvilleHousing
    SET SoldAsVacant = 
CASE 
    WHEN SoldAsVacant = 'Y' THEN 'Yes'
    WHEN SoldAsVacant = 'N' then 'No'
    ELSE SoldAsVacant
END 

SELECT *
FROM NashvilleHousing


-- 5 -- Remove Duplicates

-- Detecting Duplicates
with row_numCTE as 
(
SELECT * , 
    ROW_NUMBER() OVER (
        PARTITION BY 
        ParcelID
        , PropertyAddress
        , SaleDate
        , LegalReference
        , YearBuilt ORDER by UniqueID
    ) row_numbers
FROM NashvilleHousing
--WHERE row_numbers > 1
)
SELECT *
FROM row_numCTE
WHERE row_numbers > 1




-- Delete unused columns
SELECT *
FROM NashvilleHousing

ALTER TABLE NashvilleHousing
DROP COLUMN PropertyAddress, OwnerAddress, TaxDistrict