-- 创建表
CREATE TABLE Employees (
    ID INT PRIMARY KEY,
    Name VARCHAR(50),
    Age INT,
    Country VARCHAR(50),
    Salary DECIMAL(10, 2)
);

-- 插入数据
INSERT INTO Employees (ID, Name, Age, Country, Salary) VALUES
(1, 'Alice', 30, 'USA', 70000),
(2, 'Bob', 25, 'Canada', 50000),
(3, 'Charlie', 35, 'UK', 80000);
