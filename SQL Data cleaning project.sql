

SELECT *
FROM [Portfolio Project]..[Nashville Housing]


----------------------------------------------------------------------------------------------------
--CHANGE SALE DATE----------------------------------------------------------------------------------


SELECT SaleDate, CONVERT(date, SaleDate)
FROM [Portfolio Project]..[Nashville Housing]

UPDATE [Portfolio Project]..[Nashville Housing]
SET SaleDate = CONVERT(date, SaleDate)

ALTER TABLE [Portfolio project]..[Nashville Housing]
ADD [Sale Date Converted] DATE;

UPDATE [Portfolio Project]..[Nashville Housing]
SET [Sale Date Converted] = CONVERT(date, SaleDate)


----------------------------------------------------------------------------------------------------
--POPULATE PROPERTY ADDRESS DATA--------------------------------------------------------------------


SELECT *
FROM [Portfolio Project].dbo.[Nashville Housing]
--WHERE PropertyAddress IS NULL
ORDER BY ParcelID

SELECT A.ParcelID, A.PropertyAddress, B.ParcelID, B.PropertyAddress, ISNULL(A.PropertyAddress, B.PropertyAddress)
FROM [Portfolio Project].dbo.[Nashville Housing] AS A
JOIN [Portfolio Project].dbo.[Nashville Housing] AS B
	ON A.ParcelID = B.ParcelID
	AND A.[UniqueID ] <> B.[UniqueID ]
WHERE A.PropertyAddress IS NULL

UPDATE A
SET A.PropertyAddress = ISNULL(A.PropertyAddress, B.PropertyAddress)
FROM [Portfolio Project].dbo.[Nashville Housing] AS A
JOIN [Portfolio Project].dbo.[Nashville Housing] AS B
	ON A.ParcelID = B.ParcelID
	AND A.[UniqueID ] <> B.[UniqueID ]

----------------------------------------------------------------------------------------------------
-- BREAKING ADDRESS INTO INDIVIDUAL COLUMS (ADDRESS, CITY, STATE)-----------------------------------

--BRAKES DOWN PROPERTY ADDRESS

SELECT PropertyAddress
FROM [Portfolio Project].dbo.[Nashville Housing]

SELECT 
SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) - 1) AS ADDRESS
, SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) + 1, LEN(PropertyAddress)) AS ADDRESS

FROM [Portfolio Project]..[Nashville Housing]

ALTER TABLE [Portfolio project]..[Nashville Housing]
ADD [Property Split Address] NVARCHAR(225);

UPDATE [Portfolio Project]..[Nashville Housing]
SET [Property Split Address] = SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) - 1)


ALTER TABLE [Portfolio project]..[Nashville Housing]
ADD [Property Split City] NVARCHAR(225);

UPDATE [Portfolio Project]..[Nashville Housing]
SET [Property Split City] = SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) + 1, LEN(PropertyAddress))


--BREAKES DOWN OWNER ADDRESS

SELECT
PARSENAME(REPLACE(OwnerAddress, ',', '.'), 3) AS [Owner Address]
,PARSENAME(REPLACE(OwnerAddress, ',', '.'), 2) AS [Owner City]
,PARSENAME(REPLACE(OwnerAddress, ',', '.'), 1) AS [Owner State]
FROM [Portfolio Project]..[Nashville Housing]

ALTER TABLE [Portfolio project]..[Nashville Housing]
ADD [Owner Split Address] NVARCHAR(225);

UPDATE [Portfolio Project]..[Nashville Housing]
SET [Owner Split Address] = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 3)

ALTER TABLE [Portfolio project]..[Nashville Housing]
ADD [Owner Split City] NVARCHAR(225);

UPDATE [Portfolio Project]..[Nashville Housing]
SET [Owner Split City] = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 2)

ALTER TABLE [Portfolio project]..[Nashville Housing]
ADD [Owner Split State] NVARCHAR(225);

UPDATE [Portfolio Project]..[Nashville Housing]
SET [Owner Split State] = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 1)

----------------------------------------------------------------------------------------------------
-- CHANGE Y AND N AND NO IN "SOLD AS VACENT" FIELD--------------------------------------------------


SELECT DISTINCT (SoldAsVacant), COUNT(SoldAsVacant)
FROM [Portfolio Project]..[Nashville Housing]
GROUP BY SoldAsVacant
ORDER BY 2

SELECT SoldAsVacant,
CASE 
	WHEN SoldAsVacant = 'y' THEN 'Yes'
	WHEN SoldAsVacant = 'N' THEN 'No'
	ELSE SoldAsVacant
	END
FROM [Portfolio Project]..[Nashville Housing]

UPDATE [Portfolio Project]..[Nashville Housing]
SET SoldAsVacant = CASE 
	WHEN SoldAsVacant = 'y' THEN 'Yes'
	WHEN SoldAsVacant = 'N' THEN 'No'
	ELSE SoldAsVacant
	END


----------------------------------------------------------------------------------------------------
-- REMOVING DUPLICATES------------------------------------------------------------------------------


WITH RowNumCTE AS (
SELECT *,
	ROW_NUMBER() OVER (
	PARTITION BY ParcelID,
				 PropertyAddress,
				 SalePrice,
				 SaleDate,
				 Legalreference
				 ORDER BY
					UniqueID
					) row_num

From [Portfolio Project]..[Nashville Housing]
)

DELETE
FROM RowNumCTE
WHERE row_num > 1


----------------------------------------------------------------------------------------------------
--DELETE UNUSED COLUMNS-----------------------------------------------------------------------------


SELECT *
FROM [Portfolio Project]..[Nashville Housing]

ALTER TABLE [Portfolio Project]..[Nashville Housing]
DROP COLUMN SaleDate