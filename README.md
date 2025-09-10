# Library Management System 


- **Veritabanı Oluşturma**: `library_db` adlı bir veritabanı oluşturuldu.
- **Tablo Oluşturma**: Şubeler, çalışanlar, üyeler, kitaplar, yayın durumu ve iade durumu için tablolar oluşturuldu. Her tablo ilgili sütunları ve ilişkileri içerir.

```sql
CREATE DATABASE library_db;

DROP TABLE IF EXISTS branch;
CREATE TABLE branch
(
            branch_id VARCHAR(10) PRIMARY KEY,
            manager_id VARCHAR(10),
            branch_address VARCHAR(30),
            contact_no VARCHAR(15)
);


-- Create table "Employee"
DROP TABLE IF EXISTS employees;
CREATE TABLE employees
(
            emp_id VARCHAR(10) PRIMARY KEY,
            emp_name VARCHAR(30),
            position VARCHAR(30),
            salary DECIMAL(10,2),
            branch_id VARCHAR(10),
            FOREIGN KEY (branch_id) REFERENCES  branch(branch_id)
);


-- Create table "Members"
DROP TABLE IF EXISTS members;
CREATE TABLE members
(
            member_id VARCHAR(10) PRIMARY KEY,
            member_name VARCHAR(30),
            member_address VARCHAR(30),
            reg_date DATE
);



-- Create table "Books"
DROP TABLE IF EXISTS books;
CREATE TABLE books
(
            isbn VARCHAR(50) PRIMARY KEY,
            book_title VARCHAR(80),
            category VARCHAR(30),
            rental_price DECIMAL(10,2),
            status VARCHAR(10),
            author VARCHAR(30),
            publisher VARCHAR(30)
);



-- Create table "IssueStatus"
DROP TABLE IF EXISTS issued_status;
CREATE TABLE issued_status
(
            issued_id VARCHAR(10) PRIMARY KEY,
            issued_member_id VARCHAR(30),
            issued_book_name VARCHAR(80),
            issued_date DATE,
            issued_book_isbn VARCHAR(50),
            issued_emp_id VARCHAR(10),
            FOREIGN KEY (issued_member_id) REFERENCES members(member_id),
            FOREIGN KEY (issued_emp_id) REFERENCES employees(emp_id),
            FOREIGN KEY (issued_book_isbn) REFERENCES books(isbn) 
);



-- Create table "ReturnStatus"
DROP TABLE IF EXISTS return_status;
CREATE TABLE return_status
(
            return_id VARCHAR(10) PRIMARY KEY,
            issued_id VARCHAR(30),
            return_book_name VARCHAR(80),
            return_date DATE,
            return_book_isbn VARCHAR(50),
            FOREIGN KEY (return_book_isbn) REFERENCES books(isbn)
);

```

### 2. CRUD Operations

- **Create**: Inserted sample records into the `books` table.
- **Read**: Retrieved and displayed data from various tables.
- **Update**: Updated records in the `employees` table.
- **Delete**: Removed records from the `members` table as needed.

**Görev 1. Yeni Bir Kitap Kaydı Oluşturun -- "978-1-60129-456-2', 'To Kill a Mockingbird', 'Classic', 6.00, 'yes', 'Harper Lee', 'J.B. Lippincott & Co.')**
-- "978-1-60129-456-2', 'To Kill a Mockingbird', 'Classic', 6.00, 'yes', 'Harper Lee', 'J.B. Lippincott & Co.')"

```sql
INSERT INTO books(isbn, book_title, category, rental_price, status, author, publisher)
VALUES('978-1-60129-456-2', 'To Kill a Mockingbird', 'Classic', 6.00, 'yes', 'Harper Lee', 'J.B. Lippincott & Co.');
SELECT * FROM books;
```
Görev2. Mevcut Bir Üyenin Adresini Güncelleyin

```sql
UPDATE members
SET member_address = '125 Oak St'
WHERE member_id = 'C103';
```

Görev 3: Verilen Durum Tablosundan Bir Kaydı Sil -- Amaç: issued_id = 'IS121' olan kaydı issued_status tablosundan silin.
-- Objective: Delete the record with issued_id = 'IS121' from the issued_status table.

```sql
DELETE FROM issued_status
WHERE   issued_id =   'IS121';
```

 Görev 4: Belirli Bir Çalışan Tarafından Verilen Tüm Kitapları Al -- Amaç: emp_id = 'E101' olan çalışan tarafından verilen tüm kitapları seç.
-- Objective: Select all books issued by the employee with emp_id = 'E101'.
```sql
SELECT * FROM issued_status
WHERE issued_emp_id = 'E101'
```


Görev 5: Birden Fazla Kitap Yayımlayan Üyeleri Listeleyin -- Amaç: Birden fazla kitap yayımlayan üyeleri bulmak için GROUP BY kullanın.
-- Objective: Use GROUP BY to find members who have issued more than one book.

```sql
SELECT
    issued_emp_id,
    COUNT(*)
FROM issued_status
GROUP BY 1
HAVING COUNT(*) > 1
```


 Görev 6: Özet Tabloları Oluşturun: Sorgu sonuçlarına göre yeni tablolar oluşturmak için CTAS kullanıldı - her kitap ve toplam book_issued_cnt

```sql
CREATE TABLE book_issued_cnt AS
SELECT b.isbn, b.book_title, COUNT(ist.issued_id) AS issue_count
FROM issued_status as ist
JOIN books as b
ON ist.issued_book_isbn = b.isbn
GROUP BY b.isbn, b.book_title;
```



 Görev 7. Belirli Bir Kategorideki Tüm Kitapları Al

```sql
SELECT * FROM books
WHERE category = 'Classic';
```

 Görev 8: Kategoriye Göre Toplam Kira Gelirini Bulun:

```sql
SELECT
	category,
	SUM(b.rental_price) AS total_price,
	COUNT(*)
FROM issued_status AS ist
JOIN books AS b ON ist.issued_book_isbn = b.isbn
GROUP BY 1;
```

 Görev 9 Son 180 Gün İçinde Kayıt Olan Üyeleri Listele:
```sql
SELECT * FROM members
WHERE reg_date >= CURRENT_DATE - INTERVAL '180 days';
```

Görev 10 Çalışanları Şube Müdürlerinin Adı ve şube bilgileriyle listeleyin

```sql
SELECT 
    m.emp_id,
    m.emp_name,
    m.position,
    m.salary,
    m.branch_id,
    b.*,
    m2.emp_name AS manager
FROM employees AS m
JOIN branch AS b 
    ON m.branch_id = b.branch_id       
JOIN employees AS m2 
    ON m2.emp_id = b.manager_id;  
```

Görev 11 Belirli Bir Eşiğin Üzerinde Kira Fiyatına Sahip Kitapların Tablosunu Oluşturun**:
```sql
CREATE TABLE expensive_books AS
SELECT * FROM books
WHERE rental_price > 7.00;
```

Görev 12 Henüz İade Edilmeyen Kitapların Listesini Alın
```sql
SELECT
    i.issued_id,
    i.issued_member_id,
    i.issued_book_name,
    r.return_book_name,
    r.return_id
FROM issued_status AS i
LEFT JOIN return_status AS r 
    ON r.return_book_isbn = i.issued_book_isbn
WHERE r.return_book_isbn IS NULL;
```



Görev 13 Gecikmiş Kitapları Olan Üyeleri Belirleyin

```sql
SELECT
	i.issued_member_id,
	m.member_name,
	b.book_title,
	i.issued_date,
	r.return_date
FROM issued_status AS i
JOIN members AS m
	ON member_id = i.issued_member_id
JOIN books AS b
	ON b.isbn = i.issued_book_isbn
LEFT JOIN return_status AS r
	ON r.issued_id = i.issued_id
WHERE
	r.return_date IS NULL
AND	(CURRENT_DATE - i.issued_date) > 30
ORDER BY 1;
	
```




Görev 15: Şube Performans Raporu
Her şube için, verilen kitap sayısını, iade edilen kitap sayısını ve kitap kiralamalarından elde edilen toplam geliri gösteren bir performans raporu üreten bir sorgu oluşturun.


```sql
CREATE TABLE branch_reports
AS
SELECT 
    b.branch_id,
    b.manager_id,
    COUNT(ist.issued_id) as number_book_issued,
    COUNT(rs.return_id) as number_of_book_return,
    SUM(bk.rental_price) as total_revenue
FROM issued_status as ist
JOIN 
employees as e
ON e.emp_id = ist.issued_emp_id
JOIN
branch as b
ON e.branch_id = b.branch_id
LEFT JOIN
return_status as rs
ON rs.issued_id = ist.issued_id
JOIN 
books as bk
ON ist.issued_book_isbn = bk.isbn
GROUP BY 1, 2;
SELECT * FROM branch_reports
```

Görev 16: CTAS: Aktif Üyeler Tablosu Oluşturma
Son 2 ayda en az bir kitap yayınlamış üyeleri içeren yeni bir active_members tablosu oluşturmak için CREATE TABLE AS (CTAS) ifadesini kullanın.

```sql

CREATE TABLE active_members
AS
SELECT * FROM members
WHERE member_id IN (SELECT 
                        DISTINCT issued_member_id   
                    FROM issued_status
                    WHERE 
                        issued_date >= CURRENT_DATE - INTERVAL '2 month'
                    );
SELECT * FROM active_members
```




