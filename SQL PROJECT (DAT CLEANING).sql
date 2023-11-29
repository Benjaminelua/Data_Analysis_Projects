/*
Portfolio Project For Data Cleaning

*/
-------------------------------------------------------------------------------------------------------------------------------------------------
SELECT * FROM
PortfolioProjects.[dbo].[National_Housing]

-----------------------------------------------------------------------------------------------------------------------------------------------------

-- Salesdate formatting

SELECT SaleDateConverted, CONVERT(DATE, SaleDate)
FROM PortfolioProjects.[dbo].[National_Housing]

UPDATE National_Housing
SET SaleDate =   CONVERT(DATE, SaleDate);
 
 ALTER TABLE National_Housing
 ADD SaleDateConverted DATE;

 UPDATE National_Housing
SET SaleDateConverted =   CONVERT(DATE, SaleDate);

------------------------------------------------------------------------------------------------------------------------------------------------------
--Formatting The  Property Address Data

SELECT *
FROM PortfolioProjects.[dbo].[National_Housing]
--WHERE PropertyAddress IS NULL
ORDER BY ParcelID


SELECT A.ParcelID, A.PropertyAddress, B.ParcelID, B.PropertyAddress, ISNULL( A.PropertyAddress,B.PropertyAddress)
FROM PortfolioProjects.[dbo].[National_Housing] A
JOIN PortfolioProjects.[dbo].[National_Housing] B
ON A.ParcelID = B.ParcelID
AND A.UniqueID <> B.UniqueID
WHERE A.PropertyAddress IS NULL

UPDATE A
SET A.PropertyAddress = ISNULL( A.PropertyAddress,B.PropertyAddress)
FROM PortfolioProjects.[dbo].[National_Housing] A
JOIN PortfolioProjects.[dbo].[National_Housing] B
ON A.ParcelID = B.ParcelID
AND A.UniqueID <> B.UniqueID
WHERE A.PropertyAddress IS NULL

----------------------------------------------------------------------------------------------------------------------
--Breaking out address into individual columns (Address, City, State)

SELECT PropertyAddress
FROM PortfolioProjects.[dbo].[National_Housing]
--WHERE PropertyAddress IS NULL
--ORDER BY ParcelID

SELECT SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1) AS Address,
SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress)+1, LEN(PropertyAddress)) AS Address
FROM PortfolioProjects.[dbo].[National_Housing]

ALTER TABLE National_Housing
 ADD PropertySplitAddress VARCHAR(300);

 UPDATE National_Housing
SET PropertySplitAddress = SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1)

ALTER TABLE National_Housing
 ADD PropertySplitCity VARCHAR(300);

 UPDATE National_Housing
SET PropertySplitCity = SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress)+1, LEN(PropertyAddress))

--Owner's Address

SELECT * FROM
PortfolioProjects.[dbo].[National_Housing]

SELECT PARSENAME(REPLACE(OwnerAddress,',', '.'), 3),
 PARSENAME(REPLACE(OwnerAddress,',', '.'), 2),
  PARSENAME(REPLACE(OwnerAddress,',', '.'), 1)
FROM PortfolioProjects.[dbo].[National_Housing]


ALTER TABLE National_Housing
 ADD OwnerSplitAdress VARCHAR(300);

 UPDATE National_Housing
SET OwnerSplitAdress =PARSENAME(REPLACE(OwnerAddress,',', '.'), 3) 


ALTER TABLE National_Housing
 ADD OwnerSplitCity VARCHAR(300);

 UPDATE National_Housing
SET OwnerSplitCity = PARSENAME(REPLACE(OwnerAddress,',', '.'), 2)


ALTER TABLE National_Housing
 ADD OwnerSplitState VARCHAR(300);

 UPDATE National_Housing
SET OwnerSplitState =PARSENAME(REPLACE(OwnerAddress,',', '.'), 1)

---------------------------------------------------------------------------------------------------------------------------------
--Changing Y and N to yes and no in 'sold as vacant' field

SELECT DISTINCT(SoldAsVacant), COUNT(SoldAsVacant)
FROM PortfolioProjects.[dbo].[National_Housing]
GROUP BY SoldAsVacant
ORDER BY 2

SELECT SoldAsVacant
, CASE WHEN SoldAsVacant = 'Y' THEN 'Yes'
       WHEN SoldAsVacant = 'N' THEN 'No'
	   ELSE SoldAsVacant
	   END
FROM PortfolioProjects.[dbo].[National_Housing]

UPDATE National_Housing
SET SoldAsVacant =  CASE WHEN SoldAsVacant = 'Y' THEN 'Yes'
       WHEN SoldAsVacant = 'N' THEN 'No'
	   ELSE SoldAsVacant
	   END

---------------------------------------------------------------------------------------------------------------------------------------------
--REMOVING DUBLICATES

WITH ROWNUMCTE AS(
SELECT *,
ROW_NUMBER() OVER (
    PARTITION BY ParcelID,
	           PropertyAddress,
			   SalePrice,
			   SaleDate,
			   LegalReference
			   ORDER BY UniqueID
			     )ROW_NUM
FROM PortfolioProjects.[dbo].[National_Housing]
--ORDER BY ParcelID
      )

SELECT *
FROM ROWNUMCTE
WHERE ROW_NUM > 1
ORDER BY PropertyAddress

----------------------------------------------------------------------------------------------------------------------------------------
--Delecting Unused Columns

SELECT * FROM
PortfolioProjects.[dbo].[National_Housing]

ALTER TABLE PortfolioProjects.[dbo].[National_Housing]
DROP COLUMN OwnerAddress, PropertyAddress, TaxDistrict

ALTER TABLE PortfolioProjects.[dbo].[National_Housing]
DROP COLUMN SaleDate