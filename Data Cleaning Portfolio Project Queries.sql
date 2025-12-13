/*
Cleaning Data in SQL Queries
*/

Select *
From PortfolioProject.dbo.NashvilleHousing


--------------------------------------------------------------------------------------------------
-- Standardize Date Format


Select
    SaleDate,
    CONVERT(date, SaleDate) as SaleDateConverted
From PortfolioProject.dbo.NashvilleHousing


-- Update SaleDate if possible

Update NashvilleHousing
SET SaleDate = CONVERT(date, SaleDate)


-- If the update does not work properly, create a new column

ALTER TABLE NashvilleHousing
Add SaleDateConverted date;

Update NashvilleHousing
SET SaleDateConverted = CONVERT(date, SaleDate)


--------------------------------------------------------------------------------------------------
-- Populate Property Address data


Select *
From PortfolioProject.dbo.NashvilleHousing
Order by ParcelID


-- Use self join to fill missing PropertyAddress

Select
    a.ParcelID,
    a.PropertyAddress,
    b.PropertyAddress,
    ISNULL(a.PropertyAddress, b.PropertyAddress) as UpdatedAddress
From PortfolioProject.dbo.NashvilleHousing a
Join PortfolioProject.dbo.NashvilleHousing b
    On a.ParcelID = b.ParcelID
   and a.[UniqueID ] <> b.[UniqueID ]
Where a.PropertyAddress is null


Update a
Set PropertyAddress = ISNULL(a.PropertyAddress, b.PropertyAddress)
From PortfolioProject.dbo.NashvilleHousing a
Join PortfolioProject.dbo.NashvilleHousing b
    On a.ParcelID = b.ParcelID
   and a.[UniqueID ] <> b.[UniqueID ]
Where a.PropertyAddress is null


--------------------------------------------------------------------------------------------------
-- Break out PropertyAddress into Address and City


Select PropertyAddress
From PortfolioProject.dbo.NashvilleHousing


Select
    SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) - 1) as PropertySplitAddress,
    SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) + 1, LEN(PropertyAddress)) as PropertySplitCity
From PortfolioProject.dbo.NashvilleHousing


ALTER TABLE NashvilleHousing
Add PropertySplitAddress nvarchar(255);

Update NashvilleHousing
Set PropertySplitAddress =
    SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) - 1)


ALTER TABLE NashvilleHousing
Add PropertySplitCity nvarchar(255);

Update NashvilleHousing
Set PropertySplitCity =
    SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) + 1, LEN(PropertyAddress))


Select *
From PortfolioProject.dbo.NashvilleHousing


--------------------------------------------------------------------------------------------------
-- Break out OwnerAddress into Address, City, State


Select OwnerAddress
From PortfolioProject.dbo.NashvilleHousing


Select
    PARSENAME(REPLACE(OwnerAddress, ',', '.'), 3) as OwnerSplitAddress,
    PARSENAME(REPLACE(OwnerAddress, ',', '.'), 2) as OwnerSplitCity,
    PARSENAME(REPLACE(OwnerAddress, ',', '.'), 1) as OwnerSplitState
From PortfolioProject.dbo.NashvilleHousing


ALTER TABLE NashvilleHousing
Add OwnerSplitAddress nvarchar(255);

Update NashvilleHousing
Set OwnerSplitAddress =
    PARSENAME(REPLACE(OwnerAddress, ',', '.'), 3)


ALTER TABLE NashvilleHousing
Add OwnerSplitCity nvarchar(255);

Update NashvilleHousing
Set OwnerSplitCity =
    PARSENAME(REPLACE(OwnerAddress, ',', '.'), 2)


ALTER TABLE NashvilleHousing
Add OwnerSplitState nvarchar(255);

Update NashvilleHousing
Set OwnerSplitState =
    PARSENAME(REPLACE(OwnerAddress, ',', '.'), 1)


Select *
From PortfolioProject.dbo.NashvilleHousing


--------------------------------------------------------------------------------------------------
-- Change Y and N to Yes and No in SoldAsVacant field


Select
    SoldAsVacant,
    COUNT(*) as Count
From PortfolioProject.dbo.NashvilleHousing
Group by SoldAsVacant
Order by Count


Select
    SoldAsVacant,
    Case
        When SoldAsVacant = 'Y' Then 'Yes'
        When SoldAsVacant = 'N' Then 'No'
        Else SoldAsVacant
    End as CleanedSoldAsVacant
From PortfolioProject.dbo.NashvilleHousing


Update NashvilleHousing
Set SoldAsVacant =
    Case
        When SoldAsVacant = 'Y' Then 'Yes'
        When SoldAsVacant = 'N' Then 'No'
        Else SoldAsVacant
    End


--------------------------------------------------------------------------------------------------
-- Remove duplicates


With RowNumCTE as
(
    Select *,
        ROW_NUMBER() Over (
            Partition by
                ParcelID,
                PropertyAddress,
                SalePrice,
                SaleDate,
                LegalReference
            Order by UniqueID
        ) as row_num
    From PortfolioProject.dbo.NashvilleHousing
)
Select *
From RowNumCTE
Where row_num > 1
Order by PropertyAddress


-- (Optional) Delete duplicates after reviewing

-- Delete
-- From RowNumCTE
-- Where row_num > 1


--------------------------------------------------------------------------------------------------
-- Remove unused columns


Select *
From PortfolioProject.dbo.NashvilleHousing


ALTER TABLE PortfolioProject.dbo.NashvilleHousing
Drop Column OwnerAddress, TaxDistrict, PropertyAddress, SaleDate



--------------------------------------------------------------------------------------------------
-- Importing data using OPENROWSET and BULK INSERT
-- Advanced option, requires server configuration
-- Included here for reference


-- sp_configure 'show advanced options', 1;
-- RECONFIGURE;

-- sp_configure 'Ad Hoc Distributed Queries', 1;
-- RECONFIGURE;


-- BULK INSERT example

-- BULK INSERT NashvilleHousing
-- From 'C:\Temp\NashvilleHousing.csv'
-- With (
--     FIELDTERMINATOR = ',',
--     ROWTERMINATOR = '\n'
-- );


-- OPENROWSET example

-- Select *
-- Into NashvilleHousing
-- From OPENROWSET(
--     'Microsoft.ACE.OLEDB.12.0',
--     'Excel 12.0; Database=C:\Temp\NashvilleHousing.xlsx',
--     'Sheet1$'
-- );
