/* 

Cleaning Data in SQL Queries

*/

SELECT		*
FROM		PortfolioProject.dbo.NashvilleHousing

-----------------------------------------------------------------------------------------------------------------------------------

-- Standardize Date Format

SELECT		SaleDate, CONVERT(DATE,SaleDate)
FROM		PortfolioProject.dbo.NashvilleHousing

UPDATE		NashvilleHousing
SET			SaleDate = CONVERT(DATE,SaleDate)

ALTER	TABLE	NashvilleHousing
ADD				SaleDateConverted	DATE ;

UPDATE			NashvilleHousing
SET				SaleDateConverted =CONVERT(DATE,SaleDate)

-----------------------------------------------------------------------------------------------------------------------------------

-- Populate Property Address Data


SELECT		PropertyAddress
FROM		PortfolioProject.dbo.NashvilleHousing
WHERE		PropertyAddress IS NULL

SELECT		a.ParcelID,a.PropertyAddress,b.ParcelID,b.ParcelID, ISNULL(a.PropertyAddress,b.PropertyAddress)
FROM		PortfolioProject.dbo.NashvilleHousing  a
JOIN		PortfolioProject.dbo.NashvilleHousing  b
ON			a.ParcelID = b.ParcelID
AND			a.[UniqueID ] <> b.[UniqueID ]
WHERE		a.PropertyAddress IS NULL


UPDATE		a
SET			PropertyAddress = ISNULL(a.PropertyAddress,b.PropertyAddress)
FROM		PortfolioProject.dbo.NashvilleHousing  a
JOIN		PortfolioProject.dbo.NashvilleHousing  b
ON			a.ParcelID = b.ParcelID
AND			a.[UniqueID ] <> b.[UniqueID ]
WHERE		a.PropertyAddress IS NULL

SELECT		a.ParcelID,a.PropertyAddress,b.ParcelID,b.ParcelID, ISNULL(a.PropertyAddress,b.PropertyAddress)
FROM		PortfolioProject.dbo.NashvilleHousing  a
JOIN		PortfolioProject.dbo.NashvilleHousing  b
ON			a.ParcelID = b.ParcelID
AND			a.[UniqueID ] <> b.[UniqueID ]
WHERE		a.PropertyAddress IS NULL
CASE
    WHEN condition1 THEN result1
    WHEN condition2 THEN result2
    WHEN conditionN THEN resultN
    ELSE result
END;


------------------------------------------------------------------------------------------------------------------------------------

-- Breaking out Address into Indicidual Columns (Address , City, State)

SELECT			 SUBSTRING(PropertyAddress , 1,  CHARINDEX (',' , PropertyAddress)- 1) AS Address
				,SUBSTRING(PropertyAddress , CHARINDEX (',' , PropertyAddress)+1 ,LEN(PropertyAddress)) AS City
FROM			 PortfolioProject.dbo.NashvilleHousing

ALTER	TABLE	 NashvilleHousing
ADD				 PropertySplitAddress NVARCHAR(255) ;

UPDATE			 NashvilleHousing
SET				 PropertySplitAddress =SUBSTRING(PropertyAddress , 1,  CHARINDEX (',' , PropertyAddress)- 1) 

ALTER	TABLE	 NashvilleHousing
ADD				 PropertySplitCity NVARCHAR(255) ;

UPDATE			 NashvilleHousing
SET				 PropertySplitCity =SUBSTRING(PropertyAddress , CHARINDEX (',' , PropertyAddress)+1 ,LEN(PropertyAddress)) 


SELECT			 OwnerAddress
FROM			 PortfolioProject.dbo.NashvilleHousing


SELECT			 PARSENAME(REPLACE(OwnerAddress, ',', '.' ),3 ) Address
				,PARSENAME(REPLACE(OwnerAddress, ',', '.' ),2 ) City
				,PARSENAME(REPLACE(OwnerAddress, ',', '.' ),1 ) State
FROM			 PortfolioProject.dbo.NashvilleHousing


ALTER	TABLE	NashvilleHousing
ADD				OwnerSplitAddress NVARCHAR(255) ;

UPDATE			NashvilleHousing
SET				OwnerSplitAddress = PARSENAME(REPLACE(OwnerAddress, ',', '.' ),3 )

ALTER	TABLE	NashvilleHousing
ADD				OwnerSplitCity NVARCHAR(255) ;

UPDATE			NashvilleHousing
SET				OwnerSplitCity = PARSENAME(REPLACE(OwnerAddress, ',', '.' ),2 ) 

ALTER	TABLE	NashvilleHousing
ADD				OwnerSplitState NVARCHAR(255) ;

UPDATE			NashvilleHousing
SET				OwnerSplitState  = PARSENAME(REPLACE(OwnerAddress, ',', '.' ),1 )

--------------------------------------------------------------------------------------------------------------------------------------------

-- Change Y and N to Yes and No in "Sold as Vacant" field 


SELECT		DISTINCT(SoldasVacant) , COUNT (SoldAsVacant)
FROM		PortfolioProject.dbo.NashvilleHousing
GROUP BY	SoldAsVacant
ORDER BY	2

SELECT		SoldasVacant,
CASE
    WHEN SoldasVacant = 'Y' THEN  'Yes'
    WHEN SoldasVacant = 'N' THEN  'No'
    ELSE SoldasVacant
END
FROM		PortfolioProject.dbo.NashvilleHousing

UPDATE			NashvilleHousing
SET				SoldasVacant =	CASE
									WHEN SoldasVacant = 'Y' THEN  'Yes'
								    WHEN SoldasVacant = 'N' THEN  'No'
									ELSE SoldasVacant
								END
---------------------------------------------------------------------------------------------------------------------------------

-- Remove Duplicates

With	RowNumCTE	AS
(
	SELECT		*,
				ROW_NUMBER() OVER( PARTITION BY ParcelID, 
										   PropertyAddress,
										   SalePrice,
										   SaleDate,
										   LegalReference
							  ORDER BY     UniqueID
							  ) row_num
FROM		PortfolioProject.dbo.NashvilleHousing
)

DELETE
FROM		RowNumCTE
WHERE		row_num > 1

SELECT		*
FROM		RowNumCTE
WHERE		row_num > 1


----------------------------------------------------------------------------------------------------------------------------------------

-- Delete Unused Columns

SELECT		*
FROM		PortfolioProject.dbo.NashvilleHousing


ALTER	TABLE		NashvilleHousing
DROP	COLUMN		OwnerAddress,TaxDistrict,PropertyAddress,SaleDate