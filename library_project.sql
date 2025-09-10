-- Görev 1. Yeni Bir Kitap Kaydı Oluşturun -- "978-1-60129-456-2', 'To Kill a Mockingbird', 'Classic', 6.00, 'yes', 'Harper Lee', 'J.B. Lippincott & Co.')"

INSERT INTO books(isbn, book_title, category, rental_price, status, author, publisher)
VALUES('978-1-60129-456-2', 'To Kill A Mockingbird', 'Classic', 6.00, 'yes', 'Harper Lee', 'J.B. Lippincott & Co.');

-- Görev 2: Mevcut Bir Üyenin Adresini Güncelleyin
SELECT members
SET member_address = '125 Oak St'
WHERE member_id = 'C103';


-- Görev 3: Verilen Durum Tablosundan Bir Kaydı Sil -- Amaç: issued_id = 'IS121' olan kaydı issued_status tablosundan silin.
DELETE FROM issued_status
WHERE issued_id = 'IS121';

-- Görev 4: Belirli Bir Çalışan Tarafından Verilen Tüm Kitapları Al -- Amaç: emp_id = 'E101' olan çalışan tarafından verilen tüm kitapları seç.
SELECT * FROM issued_status
WHERE issued_emp_id = 'E101'


-- Görev 5: Birden Fazla Kitap Yayımlayan Üyeleri Listeleyin -- Amaç: Birden fazla kitap yayımlayan üyeleri bulmak için GROUP BY kullanın.
SELECT 
	issued_emp_id,
	COUNT(*)
FROM issued_status
GROUP BY 1
HAVING COUNT(*) > 1;

-- Görev 6: Özet Tabloları Oluşturun: Sorgu sonuçlarına göre yeni tablolar oluşturmak için CTAS kullanıldı - her kitap ve toplam book_issued_cnt**
CREATE TABLE book_cnts
AS
SELECT
	b.isbn,
	b.book_title,
	COUNT(ist.issued_id) AS no_issued
FROM books AS b
JOIN
issued_status AS ist
ON ist.issued_book_isbn = b.isbn
GROUP BY 1, 2;

SELECT * FROM book_cnts;


-- Görev 7. Belirli Bir Kategorideki Tüm Kitapları Al:
SELECT * FROM books
WHERE category = 'Classic'

-- Görev 8: Kategoriye Göre Toplam Kira Gelirini Bulun:
SELECT
	category,
	SUM(b.rental_price) AS total_price,
	COUNT(*)
FROM issued_status AS ist
JOIN books AS b ON ist.issued_book_isbn = b.isbn
GROUP BY 1;

-- Görev 9 Son 180 Gün İçinde Kayıt Olan Üyeleri Listele:
SELECT * FROM members
WHERE reg_date >= CURRENT_DATE - INTERVAL '180 days';

-- Görev 10 Çalışanları Şube Müdürlerinin Adı ve şube bilgileriyle listeleyin:
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

-- Görev 11 Belirli Bir Eşiğin Üzerinde Kira Fiyatına Sahip Kitapların Tablosunu Oluşturun:
CREATE TABLE expensive_books AS
SELECT * FROM books
WHERE rental_price > 6.00;
SELECT * FROM expensive_books

-- Görev 12 Henüz İade Edilmeyen Kitapların Listesini Alın
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


-- Görev 13 Gecikmiş Kitapları Olan Üyeleri Belirleyin
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
	
	
/*
Görev 15: Şube Performans Raporu
Her şube için, verilen kitap sayısını, iade edilen kitap sayısını ve kitap kiralamalarından elde edilen toplam geliri gösteren bir performans raporu üreten bir sorgu oluşturun.
*/
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
	
/*
Görev 16: CTAS: Aktif Üyeler Tablosu Oluşturma
Son 2 ayda en az bir kitap yayınlamış üyeleri içeren yeni bir active_members tablosu oluşturmak için CREATE TABLE AS (CTAS) ifadesini kullanın.
*/
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


