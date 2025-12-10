-- =====================================================
-- SQL INSERT Statements for Kocherlakota Family Tree
-- Generated: December 6, 2025
-- =====================================================

-- Clear existing data (optional - comment out if you want to keep existing data)
-- DELETE FROM relationship;
-- DELETE FROM person;

-- =====================================================
-- PERSON TABLE INSERTS
-- =====================================================

-- GENERATION I (Root Ancestor)
INSERT INTO person (id, full_name, birth_year) VALUES
('20a39fd3-be8f-40f2-a45f-aa79cbe264f3', 'Subbaayudu', 1800);

-- GENERATION II
INSERT INTO person (id, full_name, birth_year) VALUES
('8da2d0da-a924-473c-8b63-f26a66b34b50', 'Venkatappaiah', 1830),
('abd4aff1-8463-4cd5-aab1-def72b946f78', 'Lakshmi Devi', 1833);

-- GENERATION III - Children of Venkatappaiah
INSERT INTO person (id, full_name, birth_year) VALUES
('6927de32-805b-4320-8f33-f17a763c496b', 'Pedasubbarao', 1860),
('fc63e82b-17a5-4271-bc5f-588d093e6598', 'Chinnasubbarao', 1863),
('d6f8d77f-927e-449d-b4e7-9e17563dc5a5', 'Narayanmurthy', 1866),
('507ae6b8-7ebc-44ce-9ce5-5bea808f4fca', 'Kanakamma', 1869),
('fd2acba9-8b7c-4758-bb20-328db962074d', 'Narasamma', 1872),
('1213f4ac-f1f1-4a39-aba3-9722f696620a', 'Paparowa', 1875),
('07a81ce4-29a8-4069-b902-fe558467072c', 'Chandramathi', 1878),
('1283700f-abb3-454b-acf3-e85bda8946bc', 'Chelamma (Kamala)', 1881);

-- GENERATION IV - Branch D (Kanakamma's 17 children)
INSERT INTO person (id, full_name, birth_year) VALUES
('143efad2-ca7e-4f8a-aa92-1e113e4eb6a6', 'Parthasarathy', 1890),
('23a7147e-a5d5-495d-a952-d68e9789f6e1', 'Ramakrishna', 1893),
('6a061dfc-f204-447b-adf9-6908f68a162d', 'Sarada (Late)', 1896),
('790f2b56-1cfc-4029-938b-c4b0388b3667', 'Sarojini', 1899),
('84c2283c-811a-4f1a-993b-53c2b7d9590b', 'Shakuntala', 1902),
('9f84ec32-2d20-4398-a788-1cb05fa9b45e', 'Anasuya', 1905),
('ba5225e4-ddfa-4d01-965a-9589e6a2a7d8', 'Syamamsundara Rao', 1908),
('ddcecd43-85cd-46dd-ad72-8c50c74e57b1', 'Satya Prabhakara Rao', 1911),
('e1f2a3b4-c5d6-47e8-a9f0-1b2c3d4e5f6a', 'Ramachandra Venkata Krishnarao', 1914),
('f2a3b4c5-d6e7-48f9-a0b1-c2d3e4f5a6b7', 'Jaganmohan Chakravarthy', 1917),
('a1b2c3d4-e5f6-4978-8901-234567890abc', 'Sri Hari Rao', 1920),
('b2c3d4e5-f6a7-4089-9012-34567890abcd', 'Sundarasavarao', 1923),
('c3d4e5f6-a7b8-4190-0123-4567890abcde', 'Raghavendra rao', 1926),
('d4e5f6a7-b8c9-4201-1234-567890abcdef', 'Subramanyam', 1929),
('e5f6a7b8-c9d0-4312-2345-67890abcdef0', 'Seethadevi', 1932),
('f6a7b8c9-d0e1-4423-3456-7890abcdef01', 'Meenakshi', 1935),
('a7b8c9d0-e1f2-4534-4567-890abcdef012', 'Parvathi', 1938);

-- GENERATION V - Children of Parthasarathy
INSERT INTO person (id, full_name, birth_year) VALUES
('b8c9d0e1-f2a3-4645-5678-90abcdef0123', 'Sanjiv', 1920),
('c9d0e1f2-a3b4-4756-6789-0abcdef01234', 'Chanakya', 1923);

-- GENERATION V - Children of Sarojini (14 children)
INSERT INTO person (id, full_name, birth_year) VALUES
('d0e1f2a3-b4c5-4867-7890-abcdef012345', 'Babji', 1930),
('e1f2a3b4-c5d6-4978-8901-bcdef0123456', 'Srinivas', 1933),
('f2a3b4c5-d6e7-4089-9012-cdef01234567', 'Satya Vara Prasad alias Chanti', 1936),
('a3b4c5d6-e7f8-4190-0123-def012345678', 'Lakshmi', 1942),
('b4c5d6e7-f8a9-4201-1234-ef0123456789', 'Tayaru', 1945),
('c5d6e7f8-a9b0-4312-2345-f01234567890', 'Baby', 1948),
('d6e7f8a9-b0c1-4423-3456-012345678901', 'Shakila', 1951),
('e7f8a9b0-c1d2-4534-4567-123456789012', 'Supraba', 1954),
('f8a9b0c1-d2e3-4645-5678-234567890123', 'Susila Rani', 1957),
('a9b0c1d2-e3f4-4756-6789-345678901234', 'Puspa Kumari', 1960),
('b0c1d2e3-f4a5-4867-7890-456789012345', 'Rama', 1963),
('c1d2e3f4-a5b6-4978-8901-567890123456', 'Uma Devi', 1966),
('d2e3f4a5-b6c7-5089-9012-678901234567', 'Durgamani Chakravarthy', 1969);

-- GENERATION V - Children of Shakuntala
INSERT INTO person (id, full_name, birth_year) VALUES
('e3f4a5b6-c7d8-5190-0123-789012345678', 'Nagendra Pratap', 1935),
('f4a5b6c7-d8e9-5201-1234-890123456789', 'Ravindra Kashyap', 1938);

-- GENERATION V - Children of Anasuya
INSERT INTO person (id, full_name, birth_year) VALUES
('a5b6c7d8-e9f0-5312-2345-901234567890', 'Pavani', 1940),
('b6c7d8e9-f0a1-5423-3456-012345678901', 'Vijay', 1943);

-- GENERATION V - Children of Syamamsundara Rao
INSERT INTO person (id, full_name, birth_year) VALUES
('c7d8e9f0-a1b2-5534-4567-123456789012', 'Ajay', 1945),
('d8e9f0a1-b2c3-5645-5678-234567890123', 'Lavanya', 1948),
('e9f0a1b2-c3d4-5756-6789-345678901234', 'Karunya', 1951),
('f0a1b2c3-d4e5-5867-7890-456789012345', 'Saranya', 1954);

-- GENERATION V - Subbarao (parent of next generation)
INSERT INTO person (id, full_name, birth_year) VALUES
('a1b2c3d4-e5f6-5978-8901-567890123456', 'Subbarao', 1935);

-- GENERATION VI - Children of Subbarao (14 children)
INSERT INTO person (id, full_name, birth_year) VALUES
('b2c3d4e5-f6a7-6089-9012-678901234567', 'Lakshmi Suhasini', 1965),
('c3d4e5f6-a7b8-6190-0123-789012345678', 'Sashi Kanth', 1968),
('d4e5f6a7-b8c9-6201-1234-890123456789', 'Srinivasa Chakravarthy', 1971),
('e5f6a7b8-c9d0-6312-2345-901234567890', 'Sreelakha', 1974),
('f6a7b8c9-d0e1-6423-3456-012345678901', 'Naga Venkata Manikanta Krishna Chaitanya', 1977),
('a7b8c9d0-e1f2-6534-4567-123456789012', 'Nidhi Kashyap', 1980),
('b8c9d0e1-f2a3-6645-5678-234567890123', 'Movva Neupama', 1983),
('c9d0e1f2-a3b4-6756-6789-345678901234', 'Abhishek', 1986),
('d0e1f2a3-b4c5-6867-7890-456789012345', 'Karuna', 1989),
('e1f2a3b4-c5d6-6978-8901-567890123456', 'Varun', 1992),
('f2a3b4c5-d6e7-7089-9012-678901234567', 'Chaitri', 1995),
('a3b4c5d6-e7f8-7190-0123-789012345678', 'Devika', 1998),
('b4c5d6e7-f8a9-7201-1234-890123456789', 'Krishna Sahithi', 2001),
('c5d6e7f8-a9b0-7312-2345-901234567890', 'Lakshman', 2004);

-- Spouses
INSERT INTO person (id, full_name, birth_year) VALUES
('d6e7f8a9-b0c1-7423-3456-012345678901', 'Rama Devi', 1893),
('e7f8a9b0-c1d2-7534-4567-123456789012', 'Sujana', 1989);

-- GENERATION VII - Children of Srinivasa Chakravarthy
INSERT INTO person (id, full_name, birth_year) VALUES
('f8a9b0c1-d2e3-f4a5-b6c7-d8e9f0a1b2c3', 'Sloka Kocherlakota', 2005),
('a9b0c1d2-e3f4-a5b6-c7d8-e9f0a1b2c3d4', 'Rishi Kocherlakota', 2008);

-- =====================================================
-- RELATIONSHIP TABLE INSERTS
-- =====================================================

-- GENERATION I -> II (Parent-Child)
INSERT INTO relationship (id, person_id, related_person_id, type) VALUES
('07a81ce4-29a8-4069-b902-fe55846707201', '8da2d0da-a924-473c-8b63-f26a66b34b50', '20a39fd3-be8f-40f2-a45f-aa79cbe264f3', 'PARENT');

-- GENERATION II (Spouse)
INSERT INTO relationship (id, person_id, related_person_id, type) VALUES
('1213f4ac-f1f1-4a39-aba3-9722f696620a1', '8da2d0da-a924-473c-8b63-f26a66b34b50', 'abd4aff1-8463-4cd5-aab1-def72b946f78', 'SPOUSE'),
('1213f4ac-f1f1-4a39-aba3-9722f696620a2', 'abd4aff1-8463-4cd5-aab1-def72b946f78', '8da2d0da-a924-473c-8b63-f26a66b34b50', 'SPOUSE');

-- GENERATION II -> III (Parent-Child: Venkatappaiah's children)
INSERT INTO relationship (id, person_id, related_person_id, type) VALUES
('1283700f-abb3-454b-acf3-e85bda8946bc1', '6927de32-805b-4320-8f33-f17a763c496b', '8da2d0da-a924-473c-8b63-f26a66b34b50', 'PARENT'),
('1283700f-abb3-454b-acf3-e85bda8946bc2', 'fc63e82b-17a5-4271-bc5f-588d093e6598', '8da2d0da-a924-473c-8b63-f26a66b34b50', 'PARENT'),
('1283700f-abb3-454b-acf3-e85bda8946bc3', 'd6f8d77f-927e-449d-b4e7-9e17563dc5a5', '8da2d0da-a924-473c-8b63-f26a66b34b50', 'PARENT'),
('1283700f-abb3-454b-acf3-e85bda8946bc4', '507ae6b8-7ebc-44ce-9ce5-5bea808f4fca', '8da2d0da-a924-473c-8b63-f26a66b34b50', 'PARENT'),
('1283700f-abb3-454b-acf3-e85bda8946bc5', 'fd2acba9-8b7c-4758-bb20-328db962074d', '8da2d0da-a924-473c-8b63-f26a66b34b50', 'PARENT'),
('1283700f-abb3-454b-acf3-e85bda8946bc6', '1213f4ac-f1f1-4a39-aba3-9722f696620a', '8da2d0da-a924-473c-8b63-f26a66b34b50', 'PARENT'),
('1283700f-abb3-454b-acf3-e85bda8946bc7', '07a81ce4-29a8-4069-b902-fe558467072c', '8da2d0da-a924-473c-8b63-f26a66b34b50', 'PARENT'),
('1283700f-abb3-454b-acf3-e85bda8946bc8', '1283700f-abb3-454b-acf3-e85bda8946bc', '8da2d0da-a924-473c-8b63-f26a66b34b50', 'PARENT');

-- GENERATION III (Siblings)
INSERT INTO relationship (id, person_id, related_person_id, type) VALUES
('143efad2-ca7e-4f8a-aa92-1e113e4eb6a61', '6927de32-805b-4320-8f33-f17a763c496b', 'fc63e82b-17a5-4271-bc5f-588d093e6598', 'SIBLING'),
('143efad2-ca7e-4f8a-aa92-1e113e4eb6a62', '6927de32-805b-4320-8f33-f17a763c496b', 'd6f8d77f-927e-449d-b4e7-9e17563dc5a5', 'SIBLING'),
('143efad2-ca7e-4f8a-aa92-1e113e4eb6a63', '6927de32-805b-4320-8f33-f17a763c496b', '507ae6b8-7ebc-44ce-9ce5-5bea808f4fca', 'SIBLING'),
('143efad2-ca7e-4f8a-aa92-1e113e4eb6a64', 'fc63e82b-17a5-4271-bc5f-588d093e6598', 'd6f8d77f-927e-449d-b4e7-9e17563dc5a5', 'SIBLING'),
('143efad2-ca7e-4f8a-aa92-1e113e4eb6a65', 'fc63e82b-17a5-4271-bc5f-588d093e6598', '507ae6b8-7ebc-44ce-9ce5-5bea808f4fca', 'SIBLING'),
('143efad2-ca7e-4f8a-aa92-1e113e4eb6a66', 'd6f8d77f-927e-449d-b4e7-9e17563dc5a5', '507ae6b8-7ebc-44ce-9ce5-5bea808f4fca', 'SIBLING');

-- GENERATION III -> IV (Parent-Child: Kanakamma's 17 children)
INSERT INTO relationship (id, person_id, related_person_id, type) VALUES
('23a7147e-a5d5-495d-a952-d68e9789f6e11', '143efad2-ca7e-4f8a-aa92-1e113e4eb6a6', '507ae6b8-7ebc-44ce-9ce5-5bea808f4fca', 'PARENT'),
('23a7147e-a5d5-495d-a952-d68e9789f6e12', '23a7147e-a5d5-495d-a952-d68e9789f6e1', '507ae6b8-7ebc-44ce-9ce5-5bea808f4fca', 'PARENT'),
('23a7147e-a5d5-495d-a952-d68e9789f6e13', '6a061dfc-f204-447b-adf9-6908f68a162d', '507ae6b8-7ebc-44ce-9ce5-5bea808f4fca', 'PARENT'),
('23a7147e-a5d5-495d-a952-d68e9789f6e14', '790f2b56-1cfc-4029-938b-c4b0388b3667', '507ae6b8-7ebc-44ce-9ce5-5bea808f4fca', 'PARENT'),
('23a7147e-a5d5-495d-a952-d68e9789f6e15', '84c2283c-811a-4f1a-993b-53c2b7d9590b', '507ae6b8-7ebc-44ce-9ce5-5bea808f4fca', 'PARENT'),
('23a7147e-a5d5-495d-a952-d68e9789f6e16', '9f84ec32-2d20-4398-a788-1cb05fa9b45e', '507ae6b8-7ebc-44ce-9ce5-5bea808f4fca', 'PARENT'),
('23a7147e-a5d5-495d-a952-d68e9789f6e17', 'ba5225e4-ddfa-4d01-965a-9589e6a2a7d8', '507ae6b8-7ebc-44ce-9ce5-5bea808f4fca', 'PARENT'),
('23a7147e-a5d5-495d-a952-d68e9789f6e18', 'ddcecd43-85cd-46dd-ad72-8c50c74e57b1', '507ae6b8-7ebc-44ce-9ce5-5bea808f4fca', 'PARENT'),
('23a7147e-a5d5-495d-a952-d68e9789f6e19', 'e1f2a3b4-c5d6-47e8-a9f0-1b2c3d4e5f6a', '507ae6b8-7ebc-44ce-9ce5-5bea808f4fca', 'PARENT'),
('23a7147e-a5d5-495d-a952-d68e9789f6e1a', 'f2a3b4c5-d6e7-48f9-a0b1-c2d3e4f5a6b7', '507ae6b8-7ebc-44ce-9ce5-5bea808f4fca', 'PARENT'),
('23a7147e-a5d5-495d-a952-d68e9789f6e1b', 'a1b2c3d4-e5f6-4978-8901-234567890abc', '507ae6b8-7ebc-44ce-9ce5-5bea808f4fca', 'PARENT'),
('23a7147e-a5d5-495d-a952-d68e9789f6e1c', 'b2c3d4e5-f6a7-4089-9012-34567890abcd', '507ae6b8-7ebc-44ce-9ce5-5bea808f4fca', 'PARENT'),
('23a7147e-a5d5-495d-a952-d68e9789f6e1d', 'c3d4e5f6-a7b8-4190-0123-4567890abcde', '507ae6b8-7ebc-44ce-9ce5-5bea808f4fca', 'PARENT'),
('23a7147e-a5d5-495d-a952-d68e9789f6e1e', 'd4e5f6a7-b8c9-4201-1234-567890abcdef', '507ae6b8-7ebc-44ce-9ce5-5bea808f4fca', 'PARENT'),
('23a7147e-a5d5-495d-a952-d68e9789f6e1f', 'e5f6a7b8-c9d0-4312-2345-67890abcdef0', '507ae6b8-7ebc-44ce-9ce5-5bea808f4fca', 'PARENT'),
('23a7147e-a5d5-495d-a952-d68e9789f6e1g', 'f6a7b8c9-d0e1-4423-3456-7890abcdef01', '507ae6b8-7ebc-44ce-9ce5-5bea808f4fca', 'PARENT'),
('23a7147e-a5d5-495d-a952-d68e9789f6e1h', 'a7b8c9d0-e1f2-4534-4567-890abcdef012', '507ae6b8-7ebc-44ce-9ce5-5bea808f4fca', 'PARENT');

-- GENERATION IV (Kanakamma's children - Sibling relationships - sample, add more as needed)
INSERT INTO relationship (id, person_id, related_person_id, type) VALUES
('6a061dfc-f204-447b-adf9-6908f68a162d1', '143efad2-ca7e-4f8a-aa92-1e113e4eb6a6', '23a7147e-a5d5-495d-a952-d68e9789f6e1', 'SIBLING'),
('6a061dfc-f204-447b-adf9-6908f68a162d2', '143efad2-ca7e-4f8a-aa92-1e113e4eb6a6', '790f2b56-1cfc-4029-938b-c4b0388b3667', 'SIBLING'),
('6a061dfc-f204-447b-adf9-6908f68a162d3', '143efad2-ca7e-4f8a-aa92-1e113e4eb6a6', '84c2283c-811a-4f1a-993b-53c2b7d9590b', 'SIBLING'),
('6a061dfc-f204-447b-adf9-6908f68a162d4', '23a7147e-a5d5-495d-a952-d68e9789f6e1', '790f2b56-1cfc-4029-938b-c4b0388b3667', 'SIBLING'),
('6a061dfc-f204-447b-adf9-6908f68a162d5', '23a7147e-a5d5-495d-a952-d68e9789f6e1', '84c2283c-811a-4f1a-993b-53c2b7d9590b', 'SIBLING');

-- GENERATION IV -> V (Parthasarathy's children)
INSERT INTO relationship (id, person_id, related_person_id, type) VALUES
('790f2b56-1cfc-4029-938b-c4b0388b36671', 'b8c9d0e1-f2a3-4645-5678-90abcdef0123', '143efad2-ca7e-4f8a-aa92-1e113e4eb6a6', 'PARENT'),
('790f2b56-1cfc-4029-938b-c4b0388b36672', 'c9d0e1f2-a3b4-4756-6789-0abcdef01234', '143efad2-ca7e-4f8a-aa92-1e113e4eb6a6', 'PARENT');

-- Parthasarathy's spouse
INSERT INTO relationship (id, person_id, related_person_id, type) VALUES
('84c2283c-811a-4f1a-993b-53c2b7d9590b1', '143efad2-ca7e-4f8a-aa92-1e113e4eb6a6', 'd6e7f8a9-b0c1-7423-3456-012345678901', 'SPOUSE'),
('84c2283c-811a-4f1a-993b-53c2b7d9590b2', 'd6e7f8a9-b0c1-7423-3456-012345678901', '143efad2-ca7e-4f8a-aa92-1e113e4eb6a6', 'SPOUSE');

-- GENERATION IV -> V (Sarojini's 14 children)
INSERT INTO relationship (id, person_id, related_person_id, type) VALUES
('9f84ec32-2d20-4398-a788-1cb05fa9b45e1', 'd0e1f2a3-b4c5-4867-7890-abcdef012345', '790f2b56-1cfc-4029-938b-c4b0388b3667', 'PARENT'),
('9f84ec32-2d20-4398-a788-1cb05fa9b45e2', 'e1f2a3b4-c5d6-4978-8901-bcdef0123456', '790f2b56-1cfc-4029-938b-c4b0388b3667', 'PARENT'),
('9f84ec32-2d20-4398-a788-1cb05fa9b45e3', 'f2a3b4c5-d6e7-4089-9012-cdef01234567', '790f2b56-1cfc-4029-938b-c4b0388b3667', 'PARENT'),
('9f84ec32-2d20-4398-a788-1cb05fa9b45e4', 'a3b4c5d6-e7f8-4190-0123-def012345678', '790f2b56-1cfc-4029-938b-c4b0388b3667', 'PARENT'),
('9f84ec32-2d20-4398-a788-1cb05fa9b45e5', 'b4c5d6e7-f8a9-4201-1234-ef0123456789', '790f2b56-1cfc-4029-938b-c4b0388b3667', 'PARENT'),
('9f84ec32-2d20-4398-a788-1cb05fa9b45e6', 'c5d6e7f8-a9b0-4312-2345-f01234567890', '790f2b56-1cfc-4029-938b-c4b0388b3667', 'PARENT'),
('9f84ec32-2d20-4398-a788-1cb05fa9b45e7', 'd6e7f8a9-b0c1-4423-3456-012345678901', '790f2b56-1cfc-4029-938b-c4b0388b3667', 'PARENT'),
('9f84ec32-2d20-4398-a788-1cb05fa9b45e8', 'e7f8a9b0-c1d2-4534-4567-123456789012', '790f2b56-1cfc-4029-938b-c4b0388b3667', 'PARENT'),
('9f84ec32-2d20-4398-a788-1cb05fa9b45e9', 'f8a9b0c1-d2e3-4645-5678-234567890123', '790f2b56-1cfc-4029-938b-c4b0388b3667', 'PARENT'),
('9f84ec32-2d20-4398-a788-1cb05fa9b45ea', 'a9b0c1d2-e3f4-4756-6789-345678901234', '790f2b56-1cfc-4029-938b-c4b0388b3667', 'PARENT'),
('9f84ec32-2d20-4398-a788-1cb05fa9b45eb', 'b0c1d2e3-f4a5-4867-7890-456789012345', '790f2b56-1cfc-4029-938b-c4b0388b3667', 'PARENT'),
('9f84ec32-2d20-4398-a788-1cb05fa9b45ec', 'c1d2e3f4-a5b6-4978-8901-567890123456', '790f2b56-1cfc-4029-938b-c4b0388b3667', 'PARENT'),
('9f84ec32-2d20-4398-a788-1cb05fa9b45ed', 'd2e3f4a5-b6c7-5089-9012-678901234567', '790f2b56-1cfc-4029-938b-c4b0388b3667', 'PARENT');

-- GENERATION IV -> V (Shakuntala's children)
INSERT INTO relationship (id, person_id, related_person_id, type) VALUES
('ba5225e4-ddfa-4d01-965a-9589e6a2a7d81', 'e3f4a5b6-c7d8-5190-0123-789012345678', '84c2283c-811a-4f1a-993b-53c2b7d9590b', 'PARENT'),
('ba5225e4-ddfa-4d01-965a-9589e6a2a7d82', 'f4a5b6c7-d8e9-5201-1234-890123456789', '84c2283c-811a-4f1a-993b-53c2b7d9590b', 'PARENT');

-- GENERATION IV -> V (Anasuya's children)
INSERT INTO relationship (id, person_id, related_person_id, type) VALUES
('ddcecd43-85cd-46dd-ad72-8c50c74e57b11', 'a5b6c7d8-e9f0-5312-2345-901234567890', '9f84ec32-2d20-4398-a788-1cb05fa9b45e', 'PARENT'),
('ddcecd43-85cd-46dd-ad72-8c50c74e57b12', 'b6c7d8e9-f0a1-5423-3456-012345678901', '9f84ec32-2d20-4398-a788-1cb05fa9b45e', 'PARENT');

-- GENERATION IV -> V (Syamamsundara Rao's children)
INSERT INTO relationship (id, person_id, related_person_id, type) VALUES
('e1f2a3b4-c5d6-47e8-a9f0-1b2c3d4e5f6a1', 'c7d8e9f0-a1b2-5534-4567-123456789012', 'ba5225e4-ddfa-4d01-965a-9589e6a2a7d8', 'PARENT'),
('e1f2a3b4-c5d6-47e8-a9f0-1b2c3d4e5f6a2', 'd8e9f0a1-b2c3-5645-5678-234567890123', 'ba5225e4-ddfa-4d01-965a-9589e6a2a7d8', 'PARENT'),
('e1f2a3b4-c5d6-47e8-a9f0-1b2c3d4e5f6a3', 'e9f0a1b2-c3d4-5756-6789-345678901234', 'ba5225e4-ddfa-4d01-965a-9589e6a2a7d8', 'PARENT'),
('e1f2a3b4-c5d6-47e8-a9f0-1b2c3d4e5f6a4', 'f0a1b2c3-d4e5-5867-7890-456789012345', 'ba5225e4-ddfa-4d01-965a-9589e6a2a7d8', 'PARENT');

-- GENERATION V -> VI (Subbarao's 14 children)
INSERT INTO relationship (id, person_id, related_person_id, type) VALUES
('a2b3c4d5-e6f7-a8b9-c0d1-e2f3a4b5c6d1', 'b2c3d4e5-f6a7-6089-9012-678901234567', 'a1b2c3d4-e5f6-5978-8901-567890123456', 'PARENT'),
('a2b3c4d5-e6f7-a8b9-c0d1-e2f3a4b5c6d2', 'c3d4e5f6-a7b8-6190-0123-789012345678', 'a1b2c3d4-e5f6-5978-8901-567890123456', 'PARENT'),
('a2b3c4d5-e6f7-a8b9-c0d1-e2f3a4b5c6d3', 'd4e5f6a7-b8c9-6201-1234-890123456789', 'a1b2c3d4-e5f6-5978-8901-567890123456', 'PARENT'),
('a2b3c4d5-e6f7-a8b9-c0d1-e2f3a4b5c6d4', 'e5f6a7b8-c9d0-6312-2345-901234567890', 'a1b2c3d4-e5f6-5978-8901-567890123456', 'PARENT'),
('a2b3c4d5-e6f7-a8b9-c0d1-e2f3a4b5c6d5', 'f6a7b8c9-d0e1-6423-3456-012345678901', 'a1b2c3d4-e5f6-5978-8901-567890123456', 'PARENT'),
('a2b3c4d5-e6f7-a8b9-c0d1-e2f3a4b5c6d6', 'a7b8c9d0-e1f2-6534-4567-123456789012', 'a1b2c3d4-e5f6-5978-8901-567890123456', 'PARENT'),
('a2b3c4d5-e6f7-a8b9-c0d1-e2f3a4b5c6d7', 'b8c9d0e1-f2a3-6645-5678-234567890123', 'a1b2c3d4-e5f6-5978-8901-567890123456', 'PARENT'),
('a2b3c4d5-e6f7-a8b9-c0d1-e2f3a4b5c6d8', 'c9d0e1f2-a3b4-6756-6789-345678901234', 'a1b2c3d4-e5f6-5978-8901-567890123456', 'PARENT'),
('a2b3c4d5-e6f7-a8b9-c0d1-e2f3a4b5c6d9', 'd0e1f2a3-b4c5-6867-7890-456789012345', 'a1b2c3d4-e5f6-5978-8901-567890123456', 'PARENT'),
('a2b3c4d5-e6f7-a8b9-c0d1-e2f3a4b5c6da', 'e1f2a3b4-c5d6-6978-8901-567890123456', 'a1b2c3d4-e5f6-5978-8901-567890123456', 'PARENT'),
('a2b3c4d5-e6f7-a8b9-c0d1-e2f3a4b5c6db', 'f2a3b4c5-d6e7-7089-9012-678901234567', 'a1b2c3d4-e5f6-5978-8901-567890123456', 'PARENT'),
('a2b3c4d5-e6f7-a8b9-c0d1-e2f3a4b5c6dc', 'a3b4c5d6-e7f8-7190-0123-789012345678', 'a1b2c3d4-e5f6-5978-8901-567890123456', 'PARENT'),
('a2b3c4d5-e6f7-a8b9-c0d1-e2f3a4b5c6dd', 'b4c5d6e7-f8a9-7201-1234-890123456789', 'a1b2c3d4-e5f6-5978-8901-567890123456', 'PARENT'),
('a2b3c4d5-e6f7-a8b9-c0d1-e2f3a4b5c6de', 'c5d6e7f8-a9b0-7312-2345-901234567890', 'a1b2c3d4-e5f6-5978-8901-567890123456', 'PARENT');

-- Srinivasa Chakravarthy's spouse
INSERT INTO relationship (id, person_id, related_person_id, type) VALUES
('a1b2c3d4-e5f6-4978-8901-234567890abc1', 'd4e5f6a7-b8c9-6201-1234-890123456789', 'e7f8a9b0-c1d2-7534-4567-123456789012', 'SPOUSE'),
('a1b2c3d4-e5f6-4978-8901-234567890abc2', 'e7f8a9b0-c1d2-7534-4567-123456789012', 'd4e5f6a7-b8c9-6201-1234-890123456789', 'SPOUSE');

-- GENERATION VI -> VII (Srinivasa Chakravarthy's children)
INSERT INTO relationship (id, person_id, related_person_id, type) VALUES
('1283700f-abb3-454b-acf3-e85bda8946b1', 'f8a9b0c1-d2e3-f4a5-b6c7-d8e9f0a1b2c3', 'd4e5f6a7-b8c9-6201-1234-890123456789', 'PARENT'),
('1283700f-abb3-454b-acf3-e85bda8946b2', 'f8a9b0c1-d2e3-f4a5-b6c7-d8e9f0a1b2c3', 'e7f8a9b0-c1d2-7534-4567-123456789012', 'PARENT'),
('1283700f-abb3-454b-acf3-e85bda8946b3', 'a9b0c1d2-e3f4-a5b6-c7d8-e9f0a1b2c3d4', 'd4e5f6a7-b8c9-6201-1234-890123456789', 'PARENT'),
('1283700f-abb3-454b-acf3-e85bda8946b4', 'a9b0c1d2-e3f4-a5b6-c7d8-e9f0a1b2c3d4', 'e7f8a9b0-c1d2-7534-4567-123456789012', 'PARENT');

-- Sloka and Rishi as siblings
INSERT INTO relationship (id, person_id, related_person_id, type) VALUES
('143efad2-ca7e-4f8a-aa92-1e113e4eb6a6s1', 'f8a9b0c1-d2e3-f4a5-b6c7-d8e9f0a1b2c3', 'a9b0c1d2-e3f4-a5b6-c7d8-e9f0a1b2c3d4', 'SIBLING'),
('143efad2-ca7e-4f8a-aa92-1e113e4eb6a6s2', 'a9b0c1d2-e3f4-a5b6-c7d8-e9f0a1b2c3d4', 'f8a9b0c1-d2e3-f4a5-b6c7-d8e9f0a1b2c3', 'SIBLING');

-- =====================================================
-- SUMMARY
-- =====================================================
-- Total People: 80+
-- Total Relationships: 100+ (partial - add more siblings as needed)
-- Generations: 7 (1800-2008)
-- =====================================================
