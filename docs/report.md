TRƯỜNG ĐẠI HỌC NAM CẦN THƠ
KHOA CÔNG NGHỆ THÔNG TIN

 

VÕ NGUYỄN GIA HUY
MSSV: 223940
LỚP: DH22KPM02



TÊN ĐỀ TÀI
PHÁT TRIỂN SÀN ORDER BOOK 
TÍCH HỢP ZKP


ĐỒ ÁN CHUYÊN NGÀNH
NGÀNH: KỸ THUẬT PHẦN MỀM
Mã số ngành: 7480103


Tháng 03-2026 
TRƯỜNG ĐẠI HỌC NAM CẦN THƠ
KHOA CÔNG NGHỆ THÔNG TIN


VÕ NGUYỄN GIA HUY
MSSV: 223940
LỚP: DH22KPM02



TÊN ĐỀ TÀI
PHÁT TRIỂN PHẦN MỀM 
QUẢN LÝ KHO ĐIỆN THOẠI


ĐỒ ÁN CHUYÊN NGÀNH
NGÀNH: KỸ THUẬT PHẦN MỀM
Mã số ngành: 7480103



CÁN BỘ HƯỚNG DẪN
ThS. ĐẶNG MẠNH HUY


Tháng 03-2026 
 
LỜI CẢM ƠN
Trước hết, em xin gửi tới các thầy, cô Khoa Công nghệ Thông tin, lời chào trân trọng, lời chúc sức khỏe và lời cảm ơn sâu sắc. Với sự quan tâm, dạy dỗ, chỉ bảo tận tình chu đáo của thầy cô, đến nay em đã có thể hoàn thành đồ án với đề tài: "Phát triển sàn Order Book tích hợp ZKP".
Đặc biệt, em xin gửi lời cảm ơn chân thành nhất đến thầy Đặng Mạnh Huy đã quan tâm giúp đỡ, hướng dẫn tận tình em hoàn thành tốt đồ án này trong thời gian vừa qua. Những buổi thảo luận, những lời khuyên quý báu và sự kiên nhẫn của thầy đã giúp em vượt qua nhiều khó khăn, từ việc thiết kế cơ sở dữ liệu đến tối ưu hóa giao diện ứng dụng.
Em cũng xin bày tỏ lòng biết ơn đến lãnh đạo Trường Đại học Nam Cần Thơ, các thầy cô Khoa Công nghệ Thông tin đã trực tiếp và gián tiếp giúp đỡ em trong suốt quá trình học tập và nghiên cứu đề tài. Môi trường học tập và nghiên cứu mà nhà trường và khoa tạo ra đã giúp em có điều kiện thuận lợi để hoàn thành đồ án.
Cuối cùng, em xin cảm ơn các bạn sinh viên đã chia sẻ kiến thức, kinh nghiệm và hỗ trợ em trong quá trình thực hiện. Sự hợp tác và tinh thần đoàn kết của các bạn đã giúp em vượt qua những trở ngại kỹ thuật và hoàn thiện đồ án một cách tốt nhất.
Với điều kiện thời gian và kinh nghiệm còn hạn chế, đồ án này không thể tránh khỏi những thiếu sót. Em rất mong nhận được sự chỉ bảo, đóng góp ý kiến của các thầy cô để em có điều kiện bổ sung, nâng cao kiến thức của mình, phục vụ tốt hơn công tác thực tế sau này.
Em xin chân thành cảm ơn!
				Cần Thơ, ngày 17 tháng 03 năm 2026
		Người thực hiện
		
		Võ Nguyễn Gia Huy


 
LỜI CAM KẾT
Em xin cam kết báo cáo đồ án này được hoàn thành dựa trên các kết quả nghiên cứu của em trong khuôn khổ của đề tài "Phát triển sàn Order Book tích hợp ZKP" và các kết quả này chưa được dùng cho bất cứ đồ án cùng cấp nào trước đó.
Cần Thơ, ngày 17 tháng 03 năm 2026
		Người thực hiện
		
		Võ Nguyễn Gia Huy

 
NHẬN XÉT CỦA GIẢNG VIÊN
	
																						
Cần Thơ, ngày 17 tháng 03 năm 2026
		Giảng Viên
		
		
ThS. Đặng Mạnh Huy
MỤC LỤC
CHƯƠNG 1 GIỚI THIỆU	1
1.1 Tổng quan đề tài	1
1.2 Mục tiêu đề tài	1
1.3 Phạm vi đề tài	2
1.4 Phân chia công việc trong nhóm	2
CHƯƠNG 2 CƠ SỞ LÝ THUYẾT	3
2.1 Hệ quản trị cơ sở dữ liệu MySQL	3
2.1.1 MySQL là gì	3
2.1.2 Các thao tác chính trong MySQL	3
2.1.3 Tính năng nâng cao của MySQL	3
2.2 Ngôn ngữ lập trình Java	4
2.2.1 Giới thiệu	4
2.2.2 Đặc điểm và tính năng chính của Java	4
2.3 Java Swing và FlatLaf	5
2.3.1 Tổng quan	5
2.3.2 Chức năng	5
2.3.3 Ưu điểm	5
2.4 JDBC	6
2.4.1 JDBC là gì	6
2.4.2 Kiến trúc	6
2.4.3 Cách thức hoạt động	6
2.4.3 Ưu điểm	7
2.5 Kiến trúc 3-Tier	7
2.5.1 Định nghĩa	7
2.5.2 Các tầng trong kiến trúc 3-Tier	7
2.6. Các mẫu thiết kế (Design Patterns)	7
2.6.1 Singleton Pattern	7
2.6.2 DAO Pattern	8
2.6.3 Template Method Pattern	8
CHƯƠNG 3 PHÂN TÍCH VÀ THIẾT KẾ HỆ THỐNG	9
3.1 Mô tả hệ thống	9
3.1.1 Giới thiệu hệ thống	9
3.1.2 Chức năng chính của hệ thống	10
3.1.3 Kiến trúc tổng quan	13
3.1.4 Quy trình hoạt động	14
3.1.5 Công nghệ sử dụng	17
3.2 Thiết kế hệ thống	17
3.2.1 Thiết kế cơ sở dữ liệu	17
3.2.2 Thiết kế sơ đồ lớp	24
3.2.3 Mô hình ERD	25
3.2.4 Thiết kế chức năng	26
3.2.5 Thiết kế kiến trúc hệ thống	32
3.2.6 Thiết kế phân quyền và bảo mật	32
CHƯƠNG 4 GIAO DIỆN HỆ THỐNG	34
4.1 Giao diện đăng nhập	34
4.2 Giao diện dashboard	35
4.3 Giao diện menu sản phẩm	35
4.4 Giao diện menu thuộc tính	36
4.5 Giao diện menu SKU	36
4.6 Giao diện menu IMEI	37
4.7 Giao diện menu nhập kho	37
4.8 Giao diện menu xuất kho	38
4.9 Giao diện menu nhà cung cấp	38
4.10 Giao diện menu thương hiệu	39
4.11 Giao diện menu danh mục sản phẩm	39
4.12 Giao diện menu tài khoản	40
4.13 Giao diện menu thống kê	40
4.14 Giao diện menu logs	41
CHƯƠNG 5 KẾT LUẬN	42
5.1 Kết luận	42
5.2 Hạn chế	43
5.3 Hướng phát triển	43
TÀI LIỆU THAM KHẢO	45
 
DANH SÁCH BẢNG
Bảng 1.1 Bảng phân chia công việc	2
Bảng 3.1 Bảng chức năng chính của hệ thống	10
Bảng 3.2 Bảng accounts	17
Bảng 3.3 Bảng categories	18
Bảng 3.4 Bảng brands	18
Bảng 3.5 Bảng products	18
Bảng 3.6 Bảng attributes	19
Bảng 3.7 Bảng attribute_options	19
Bảng 3.8 Bảng skus	19
Bảng 3.9 Bảng attribute_option_sku	20
Bảng 3.10 Bảng phone_imeis	20
Bảng 3.11 Bảng suppliers	20
Bảng 3.12 Bảng import_receipts	21
Bảng 3.13 Bảng import_details	21
Bảng 3.14 Bảng invoices	21
Bảng 3.15 Bảng invoice_details	22
Bảng 3.16 Bảng suppliers	22
Bảng 3.17 Bảng category_attribute	22
Bảng 3.18 Bảng logs	23
Bảng 3.19 Bảng đặc tả Use Case Đăng nhập	27
Bảng 3.20 Bảng đặc tả Use Case Quản lý phiếu nhập kho	27
Bảng 3.21 Bảng đặc tả Use Case Tạo phiếu nhập	28
Bảng 3.22 Bảng đặc tả Use Case Quản lý phiếu xuất	29
Bảng 3.23 Bảng đặc tả Use Case Tạo hóa đơn bán hàng	29
Bảng 3.24 Bảng đặc tả Use Case Quản lý sản phẩm	30
Bảng 3.25 Bảng đặc tả Use Case Nhắn tin nhóm	30
Bảng 3.26 Bảng đặc tả Use Case Xem thống kê chi tiết	31
 
DANH SÁCH HÌNH
Hình 3.1 Activity – Đăng nhập hệ thống	14
Hình 3.2 Activity - Tạo hóa đơn	15
Hình 3.3 Activity - Tạo phiếu nhập	16
Hình 3.4 Activity – Quản lý sản phẩm	17
Hình 3.5 Sơ đồ lớp	24
Hình 3.6 Sơ đồ ERD tổng quát.	25
Hình 3.7 Sơ đồ Use Case tổng quát.	26
Hình 4.1 Giao diện đăng nhập	34
Hình 4.2 Giao diện dashboard	35
Hình 4.3 Giao diện menu sản phẩm	35
Hình 4.4 Giao diện menu thuộc tính	36
Hình 4.5 Giao diện menu SKU	36
Hình 4.6 Giao diện menu IMEI	37
Hình 4.7 Giao diện menu nhập kho	37
Hình 4.8 Giao diện menu xuất kho	38
Hình 4.9 Giao diện menu nhà cung cấp	38
Hình 4.10 Giao diện menu thương hiệu	39
Hình 4.11 Giao diện menu danh mục sản phẩm	39
Hình 4.12 Giao diện menu tài khoản	40
Hình 4.13 Giao diện menu thống kê	40
Hình 4.14 Giao diện menu logs	41
 
DANH MỤC TỪ VIẾT TẮT
TỪ VIẾT TẮT	GIẢI NGHĨA
SQL	Structured Query Language
RDBMS	Relational Database Management System
UI	User Interface
JDBC	Java Database Connectivity
JDK	Java Development Kit
JVM	Java Virtual Machine
DAO	Data Access Object
DTO	Data Transfer Object
BUS	Business Logic Layer
CRUD	Create, Read, Update, Delete
IMEI	International Mobile Equipment Identity
SKU	Stock Keeping Unit
ERD	Entity Relationship Diagram
DFD	Data Flow Diagram
MVC	Model-View-Controller
JAR	Java Archive
  
CHƯƠNG 1
GIỚI THIỆU
1.1 Tổng quan đề tài
Trong bối cảnh thị trường điện thoại di động và phụ kiện đang phát triển mạnh mẽ tại Việt Nam, các cửa hàng và doanh nghiệp kinh doanh điện thoại ngày càng đối mặt với thách thức lớn trong việc quản lý kho hàng. Với sự đa dạng về thương hiệu, dòng sản phẩm, biến thể (màu sắc, dung lượng, cấu hình) và mã IMEI riêng biệt cho từng thiết bị, việc quản lý thủ công trở nên phức tạp, dễ sai sót và thiếu hiệu quả.
Đề tài "Phát triển phần mềm quản lý kho điện thoại" hướng đến việc xây dựng một ứng dụng desktop giúp các cửa hàng và doanh nghiệp kinh doanh điện thoại quản lý toàn bộ hoạt động kho hàng một cách hiệu quả. Ứng dụng cung cấp các chức năng quản lý sản phẩm, biến thể sản phẩm (SKU), theo dõi mã IMEI, quản lý nhập kho từ nhà cung cấp, xuất kho bán hàng, đồng thời hỗ trợ thống kê doanh thu và lợi nhuận.
Lý do lựa chọn đề tài này xuất phát từ nhu cầu thực tế của các cửa hàng kinh doanh điện thoại, nơi mà việc quản lý kho hàng với hàng nghìn sản phẩm, nhiều biến thể và mã IMEI riêng biệt đòi hỏi một giải pháp phần mềm chuyên biệt. Các phần mềm quản lý kho thông thường thường không hỗ trợ quản lý IMEI, thuộc tính động theo danh mục sản phẩm hay phân quyền người dùng phù hợp với quy mô cửa hàng nhỏ và vừa.
Bên cạnh đó, đề tài còn giúp nhóm nghiên cứu và áp dụng các kiến thức về lập trình hướng đối tượng với Java, thiết kế cơ sở dữ liệu quan hệ với MySQL, kiến trúc phần mềm 3 lớp và các mẫu thiết kế phổ biến, từ đó nâng cao năng lực phát triển phần mềm thực tế.
1.2 Mục tiêu đề tài
Mục tiêu của đề tài là phát triển một phần mềm quản lý kho điện thoại hoàn chỉnh, đáp ứng nhu cầu quản lý của các cửa hàng kinh doanh thiết bị di động. Cụ thể, đề tài đặt ra các mục tiêu sau:
-	Xây dựng hệ thống quản lý sản phẩm với khả năng phân loại theo thương hiệu, danh mục và hỗ trợ nhiều biến thể (SKU) cho mỗi sản phẩm.
-	Triển khai chức năng theo dõi mã IMEI cho từng thiết bị, hỗ trợ quản lý trạng thái (còn hàng, đã bán, bảo hành, lỗi).
-	Phát triển module nhập kho và xuất kho với khả năng tự động cập nhật tồn kho và trạng thái IMEI.
-	Thiết kế giao diện người dùng trực quan, dễ sử dụng và hỗ trợ thao tác nhanh chóng.
-	Xây dựng hệ thống phân quyền Admin/Nhân viên và ghi nhật ký hoạt động hệ thống.
-	Cung cấp chức năng thống kê doanh thu, lợi nhuận và cảnh báo tồn kho thấp.
1.3 Phạm vi đề tài
Nghiên cứu và phát triển ứng dụng quản lý kho điện thoại cho môi trường desktop, tập trung vào các chức năng quản lý sản phẩm, biến thể, IMEI, nhập kho, xuất kho và thống kê.
Xây dựng giao diện người dùng trực quan với Java Swing và FlatLaf, đảm bảo trải nghiệm sử dụng hiện đại và thân thiện.
Sử dụng cơ sở dữ liệu MySQL để lưu trữ và truy xuất dữ liệu, đảm bảo tính toàn vẹn và hiệu suất.
Áp dụng kiến trúc 3-Tier kết hợp các mẫu thiết kế phần mềm để đảm bảo tính bảo trì và mở rộng.
Đánh giá hiệu năng và tính ổn định của ứng dụng qua các bài kiểm thử nội bộ.
1.4 Phân chia công việc trong nhóm
Bảng 1.1 Bảng phân chia công việc
MSSV	Họ tên	Việc được phân chia	Mức độ hoàn thành
223940	Võ Nguyễn Gia Huy	- Vẽ sơ đồ Class.
- Viết backend.
- Thiết kế giao diện.
- Viết tài liệu và báo cáo.
- Phân tích các chức năng.
- Phân tích cơ sở dữ liệu.	100%
223767	Lâm Hòa Hộp	- Vẽ sơ đồ Use Case, ERD, Activity.
- Viết backend.
- Thiết kế giao diện.
- Phân tích các chức năng.
- Phân tích cơ sở dữ liệu.	100%
CHƯƠNG 2
CƠ SỞ LÝ THUYẾT
2.1 Hệ quản trị cơ sở dữ liệu MySQL
2.1.1 MySQL là gì
MySQL là một hệ quản trị cơ sở dữ liệu quan hệ (RDBMS) mã nguồn mở phổ biến nhất thế giới, được phát triển bởi Oracle Corporation. MySQL sử dụng ngôn ngữ truy vấn cấu trúc SQL (Structured Query Language) để quản lý và thao tác dữ liệu. Với hiệu suất cao, tính ổn định và khả năng mở rộng tốt, MySQL được sử dụng rộng rãi trong các ứng dụng từ quy mô nhỏ đến các hệ thống doanh nghiệp lớn.
MySQL hỗ trợ nhiều nền tảng hệ điều hành bao gồm Windows, Linux và macOS, đồng thời tương thích với hầu hết các ngôn ngữ lập trình phổ biến như Java, Python, PHP và C#. Phiên bản MySQL 8.x mang đến nhiều cải tiến về hiệu suất, bảo mật và hỗ trợ bộ ký tự Unicode đầy đủ thông qua utf8mb4.
2.1.2 Các thao tác chính trong MySQL
MySQL sử dụng ngôn ngữ SQL tiêu chuẩn để thực hiện các thao tác với dữ liệu. Một số lệnh quan trọng bao gồm:
-	SELECT: Truy vấn dữ liệu từ bảng.
-	INSERT: Thêm dữ liệu mới vào bảng.
-	UPDATE: Cập nhật dữ liệu hiện có.
-	DELETE: Xóa dữ liệu khỏi bảng.
-	CREATE: Tạo bảng, cơ sở dữ liệu, chỉ mục và các đối tượng khác.
-	ALTER: Thay đổi cấu trúc của bảng hoặc đối tượng trong cơ sở dữ liệu.
-	DROP: Xóa bảng, cơ sở dữ liệu hoặc các đối tượng khác.
2.1.3 Tính năng nâng cao của MySQL
Ngoài các lệnh cơ bản, MySQL còn cung cấp nhiều tính năng mạnh mẽ như:
-	Stored Procedures: Lưu trữ các truy vấn và logic xử lý dữ liệu để tối ưu hóa hiệu suất và tái sử dụng.
-	Triggers: Tự động thực thi khi có sự kiện INSERT, UPDATE hoặc DELETE xảy ra trong cơ sở dữ liệu.
-	Views: Tạo bảng ảo giúp tối ưu truy vấn và bảo mật dữ liệu.
-	Transactions: Đảm bảo tính toàn vẹn của dữ liệu với cơ chế ACID và các thao tác COMMIT, ROLLBACK.
-	Foreign Key Constraints: Đảm bảo tính toàn vẹn tham chiếu giữa các bảng, hỗ trợ CASCADE để tự động cập nhật hoặc xóa dữ liệu liên quan.
-	InnoDB Storage Engine: Engine lưu trữ mặc định hỗ trợ transactions, foreign keys và row-level locking, đảm bảo hiệu suất cao cho các ứng dụng có nhiều thao tác ghi đồng thời.
2.2 Ngôn ngữ lập trình Java
2.2.1 Giới thiệu
Java là một ngôn ngữ lập trình hướng đối tượng, đa nền tảng, được phát triển bởi Sun Microsystems (nay thuộc Oracle Corporation) và giới thiệu lần đầu tiên vào năm 1995. Java được thiết kế với triết lý "Write Once, Run Anywhere" (WORA), cho phép mã nguồn được biên dịch thành bytecode và chạy trên bất kỳ nền tảng nào có cài đặt Java Virtual Machine (JVM). Ngôn ngữ này được sử dụng rộng rãi trong phát triển ứng dụng desktop, web, di động và hệ thống nhúng.
2.2.2 Đặc điểm và tính năng chính của Java
Lập trình hướng đối tượng: Java tuân thủ chặt chẽ các nguyên tắc của lập trình hướng đối tượng bao gồm đóng gói (Encapsulation), kế thừa (Inheritance), đa hình (Polymorphism) và trừu tượng (Abstraction), tạo điều kiện cho việc tái sử dụng mã nguồn và phát triển các ứng dụng phức tạp một cách hiệu quả.
Quản lý bộ nhớ tự động: Nhờ cơ chế thu gom rác (Garbage Collection), Java tự động giải phóng bộ nhớ không còn được sử dụng, giúp giảm thiểu nguy cơ rò rỉ bộ nhớ và tối ưu hóa hiệu năng hệ thống.
Hệ thống kiểu tĩnh mạnh (Strong Static Type System): Java sử dụng hệ thống kiểu dữ liệu tĩnh, cho phép phát hiện lỗi trong quá trình biên dịch, từ đó tăng cường độ an toàn và độ tin cậy của mã nguồn.
Đa nền tảng: Nhờ JVM, các ứng dụng Java có thể chạy trên nhiều hệ điều hành khác nhau mà không cần biên dịch lại, giúp tăng tính linh hoạt và khả năng triển khai.
Thư viện phong phú: Java cung cấp bộ thư viện chuẩn (Java Standard Library) đồ sộ bao gồm các API hỗ trợ xử lý I/O, kết nối cơ sở dữ liệu, xây dựng giao diện đồ họa, xử lý chuỗi và nhiều tính năng khác, giúp lập trình viên phát triển ứng dụng nhanh chóng.
An toàn và bảo mật: Java có các cơ chế bảo mật tích hợp như bytecode verifier, security manager và sandboxing, giúp bảo vệ hệ thống khỏi mã độc và các lỗ hổng bảo mật.
2.3 Java Swing và FlatLaf
2.3.1 Tổng quan
Java Swing là một framework xây dựng giao diện đồ họa người dùng (GUI) thuộc bộ thư viện chuẩn của Java (Java Foundation Classes – JFC). Swing cung cấp một tập hợp phong phú các thành phần giao diện (components) như JFrame, JPanel, JTable, JButton, JTextField, JComboBox và nhiều thành phần khác, cho phép xây dựng các ứng dụng desktop với giao diện trực quan và tương tác cao.
FlatLaf là một thư viện Look and Feel hiện đại dành cho Java Swing, được phát triển bởi FormDev Software. FlatLaf mang đến giao diện phẳng (flat design), sạch sẽ và hiện đại cho các ứng dụng Swing, thay thế giao diện mặc định Metal khá lỗi thời. Phiên bản FlatLaf 3.7 được sử dụng trong đồ án này hỗ trợ cả chủ đề sáng (FlatLightLaf) và tối (FlatDarkLaf).
2.3.2 Chức năng
Java Swing kết hợp FlatLaf cung cấp một loạt các chức năng hỗ trợ xây dựng giao diện người dùng hiện đại:
-	Hệ thống Layout Manager: Cho phép sắp xếp các thành phần giao diện một cách linh hoạt với BorderLayout, FlowLayout, GridLayout, BoxLayout và CardLayout.
-	JTable với TableModel: Hỗ trợ hiển thị dữ liệu dạng bảng với khả năng sắp xếp, lọc và tùy chỉnh renderer.
-	Event Handling: Cơ chế xử lý sự kiện mạnh mẽ thông qua ActionListener, MouseListener, KeyListener, cho phép ứng dụng phản hồi tương tác người dùng.
-	Dialog System: Hỗ trợ tạo các hộp thoại (JDialog, JOptionPane) để xác nhận, thông báo và nhập liệu.
-	Giao diện hiện đại với FlatLaf: Cung cấp các thành phần UI với thiết kế phẳng, bo tròn góc, màu sắc hiện đại và hỗ trợ HiDPI.
2.3.3 Ưu điểm
Java Swing kết hợp FlatLaf được đánh giá cao nhờ vào một số ưu điểm nổi bật:
-	Đa nền tảng: Ứng dụng Swing có thể chạy trên mọi hệ điều hành có JVM mà không cần thay đổi mã nguồn.
-	Giao diện hiện đại: FlatLaf mang đến giao diện phẳng, sạch sẽ, phù hợp với xu hướng thiết kế hiện đại.
-	Tùy chỉnh linh hoạt: Hỗ trợ tùy chỉnh giao diện thông qua UIManager properties, custom renderers và Look and Feel.
-	Nhẹ và hiệu năng cao: Swing là lightweight framework, không phụ thuộc vào native components của hệ điều hành.
-	Thư viện thành phần phong phú: Cung cấp hầu hết các thành phần UI cần thiết cho ứng dụng desktop.
2.4 JDBC
2.4.1 JDBC là gì
JDBC (Java Database Connectivity) là một API tiêu chuẩn của Java, cung cấp phương thức kết nối và thao tác với các hệ quản trị cơ sở dữ liệu quan hệ từ các ứng dụng Java. JDBC định nghĩa một tập hợp các interface và class cho phép lập trình viên thực hiện các truy vấn SQL, cập nhật dữ liệu và quản lý kết nối cơ sở dữ liệu một cách thống nhất, bất kể hệ quản trị cơ sở dữ liệu nào được sử dụng.
Trong đồ án này, MySQL Connector/J phiên bản 8.4.0 được sử dụng làm JDBC driver để kết nối ứng dụng Java với cơ sở dữ liệu MySQL 8.x.
2.4.2 Kiến trúc
JDBC được thiết kế theo kiến trúc phân tầng, bao gồm các thành phần chính:
-	JDBC API: Tập hợp các interface và class trong gói java.sql và javax.sql, bao gồm Connection, Statement, PreparedStatement, ResultSet và DriverManager.
-	JDBC Driver Manager: Quản lý danh sách các driver và thiết lập kết nối giữa ứng dụng với cơ sở dữ liệu phù hợp.
-	JDBC Driver: Được cung cấp bởi nhà phát triển cơ sở dữ liệu (trong trường hợp này là MySQL Connector/J), đóng vai trò trung gian giữa ứng dụng và cơ sở dữ liệu cụ thể.
2.4.3 Cách thức hoạt động
Nạp Driver: Ứng dụng nạp JDBC driver bằng lệnh Class.forName("com.mysql.cj.jdbc.Driver"), đăng ký driver với DriverManager.
Tạo kết nối: Sử dụng DriverManager.getConnection() với URL kết nối (jdbc:mysql://localhost:3306/qlkh), tên người dùng và mật khẩu để thiết lập kết nối đến cơ sở dữ liệu MySQL.
Thực thi truy vấn: Tạo PreparedStatement từ Connection, thiết lập các tham số và thực thi truy vấn SQL. PreparedStatement giúp ngăn chặn SQL Injection và tối ưu hiệu suất.
Xử lý kết quả: Dữ liệu trả về từ truy vấn SELECT được chứa trong ResultSet, cho phép đọc từng dòng dữ liệu và chuyển đổi thành các đối tượng Java (DTO).
Đóng kết nối: Sau khi hoàn tất, đóng ResultSet, Statement và Connection để giải phóng tài nguyên.
2.4.3 Ưu điểm
Chuẩn hóa: JDBC cung cấp API thống nhất cho việc kết nối với mọi cơ sở dữ liệu quan hệ, giúp ứng dụng có thể chuyển đổi giữa các hệ quản trị cơ sở dữ liệu một cách dễ dàng.
Bảo mật: PreparedStatement hỗ trợ truy vấn tham số hóa, ngăn chặn hiệu quả tấn công SQL Injection.
Hiệu suất: PreparedStatement cho phép cơ sở dữ liệu biên dịch trước truy vấn, tối ưu hóa hiệu suất khi thực thi nhiều lần.
Tích hợp sẵn: JDBC là một phần của Java Standard Edition, không cần thêm thư viện bên ngoài (chỉ cần driver cụ thể cho từng hệ quản trị cơ sở dữ liệu).
2.5 Kiến trúc 3-Tier
2.5.1 Định nghĩa
Kiến trúc 3-Tier (Three-Tier Architecture) là một mô hình kiến trúc phần mềm phân tách ứng dụng thành ba tầng logic độc lập: tầng trình bày (Presentation Layer), tầng xử lý nghiệp vụ (Business Logic Layer) và tầng truy cập dữ liệu (Data Access Layer). Mô hình này giúp tổ chức mã nguồn rõ ràng, dễ bảo trì và mở rộng, đồng thời tuân thủ nguyên tắc phân tách quan tâm (Separation of Concerns).
2.5.2 Các tầng trong kiến trúc 3-Tier
Tầng trình bày (UI – User Interface): Chịu trách nhiệm hiển thị giao diện và tiếp nhận tương tác từ người dùng. 
Tầng xử lý nghiệp vụ (BUS – Business Logic Layer): Chịu trách nhiệm xử lý logic nghiệp vụ, xác thực dữ liệu và điều phối luồng xử lý giữa tầng UI và tầng DAO. 
Tầng truy cập dữ liệu (DAO – Data Access Object): Chịu trách nhiệm tương tác trực tiếp với cơ sở dữ liệu MySQL thông qua JDBC. 
2.6. Các mẫu thiết kế (Design Patterns)
2.6.1 Singleton Pattern
Singleton là một mẫu thiết kế thuộc nhóm Creational Pattern, đảm bảo rằng một lớp chỉ có duy nhất một thể hiện (instance) trong toàn bộ ứng dụng và cung cấp một điểm truy cập toàn cục đến thể hiện đó. Trong đồ án, Singleton Pattern được áp dụng cho lớp DatabaseHelper (quản lý kết nối cơ sở dữ liệu duy nhất) và SessionManager (quản lý phiên đăng nhập của người dùng hiện tại).
Ưu điểm của Singleton Pattern bao gồm: tiết kiệm tài nguyên hệ thống bằng cách tránh tạo nhiều đối tượng không cần thiết, đảm bảo tính nhất quán dữ liệu và cung cấp điểm truy cập duy nhất cho các thành phần dùng chung.
2.6.2 DAO Pattern
DAO (Data Access Object) là một mẫu thiết kế thuộc nhóm Structural Pattern, tách biệt logic truy cập dữ liệu khỏi logic nghiệp vụ. Mỗi đối tượng dữ liệu trong hệ thống có một lớp DAO tương ứng (ProductDAO, SkuDAO, ImeiDAO, v.v.), chịu trách nhiệm thực hiện các thao tác CRUD (Create, Read, Update, Delete) với cơ sở dữ liệu.
DAO Pattern giúp mã nguồn dễ bảo trì hơn vì mọi thay đổi liên quan đến cơ sở dữ liệu chỉ cần sửa trong lớp DAO mà không ảnh hưởng đến lớp nghiệp vụ hay giao diện. Đồng thời, mẫu thiết kế này tạo điều kiện thuận lợi cho việc kiểm thử đơn vị và chuyển đổi hệ quản trị cơ sở dữ liệu.
2.6.3 Template Method Pattern
Template Method là một mẫu thiết kế thuộc nhóm Behavioral Pattern, định nghĩa bộ khung của một thuật toán trong lớp cha và cho phép các lớp con ghi đè (override) các bước cụ thể mà không thay đổi cấu trúc tổng thể. Trong đồ án, Template Method Pattern được áp dụng trong lớp BaseCrudPanel, cung cấp bộ khung chung cho tất cả các màn hình quản lý CRUD bao gồm: bảng dữ liệu, các nút Thêm/Sửa/Xóa/Làm mới và chức năng tìm kiếm.
Các lớp con như ProductPanel, BrandPanel, CategoryPanel, SupplierPanel, v.v. kế thừa BaseCrudPanel và chỉ cần override các phương thức trừu tượng (onAddAction, onEditAction, onDeleteAction, loadData) để tùy chỉnh hành vi cho từng đối tượng quản lý cụ thể. Điều này giúp giảm đáng kể lượng mã trùng lặp và đảm bảo tính nhất quán trong giao diện người dùng.  
CHƯƠNG 3
PHÂN TÍCH VÀ THIẾT KẾ HỆ THỐNG
3.1 Mô tả hệ thống 
3.1.1 Giới thiệu hệ thống
Hệ thống được xây dựng nhằm cung cấp một giải pháp phần mềm desktop toàn diện cho việc quản lý kho hàng điện thoại và phụ kiện. Ứng dụng hướng đến việc tối ưu hóa quy trình quản lý kho hàng, từ nhập hàng từ nhà cung cấp đến xuất bán cho khách hàng, đồng thời theo dõi chi tiết từng sản phẩm, biến thể và mã IMEI.
Mục tiêu của hệ thống là tạo ra một công cụ quản lý kho hàng hiệu quả, giúp các cửa hàng kinh doanh điện thoại kiểm soát chính xác số lượng tồn kho, theo dõi nguồn gốc và trạng thái của từng thiết bị thông qua mã IMEI, đồng thời phân tích doanh thu và lợi nhuận để hỗ trợ ra quyết định kinh doanh.
Hệ thống hỗ trợ quản lý sản phẩm đa dạng bao gồm điện thoại thông minh và các phụ kiện như cáp sạc, cường lực, sạc dự phòng, củ sạc và loa. Mỗi sản phẩm có thể có nhiều biến thể (SKU) với các thuộc tính khác nhau như RAM, ROM, màu sắc, công suất, dung lượng pin, v.v. Hệ thống thuộc tính được thiết kế động theo danh mục sản phẩm, cho phép mỗi danh mục có bộ thuộc tính riêng phù hợp.
Đối tượng sử dụng hệ thống bao gồm:
-	Quản trị viên (Admin): Toàn quyền truy cập tất cả module, bao gồm quản lý tài khoản người dùng và xem nhật ký hoạt động hệ thống.
-	Nhân viên (Staff): Truy cập các module nghiệp vụ chính như quản lý sản phẩm, SKU, IMEI, nhập kho, xuất kho, nhà cung cấp, thương hiệu, danh mục, thuộc tính và thống kê.
Hệ thống giải quyết các vấn đề quản lý kho hàng thủ công kém hiệu quả, thiếu chính xác trong kiểm soát tồn kho và khó khăn trong việc theo dõi nguồn gốc thiết bị. Với việc áp dụng kiến trúc phần mềm 3-Tier, giao diện hiện đại FlatLaf và cơ sở dữ liệu MySQL, ứng dụng hứa hẹn sẽ trở thành một giải pháp quản lý kho hàng có tính ứng dụng cao, phù hợp với quy mô cửa hàng nhỏ và vừa.  
3.1.2 Chức năng chính của hệ thống
Bảng 3.1 Bảng chức năng chính của hệ thống
STT	F0	F1	F2
1		Nhân viên	Đăng nhập	
2			Đăng xuất	
3			Quản lý sản phẩm	Thêm sản phẩm
4				Sửa sản phẩm
5				Xóa sản phẩm
6				Xem sản phẩm
7			Quản lý danh mục sản phẩm	Thêm danh mục sản phẩm
8				Sửa danh mục sản phẩm
9				Xóa danh mục sản phẩm
10				Xem danh mục sản phẩm
11			Quản lý hãng sản phẩm	Thêm hãng sản phẩm
12				Sửa hãng sản phẩm
13				Xóa hãng sản phẩm
14				Xem hãng sản phẩm
15			Quản lý nhà cung cấp	Xem nhà cung cấp
16				Thêm nhà cung cấp
17				Sửa nhà cung cấp
18				Xóa nhà cung cấp
19			Quản lý phiếu nhập hàng	Thêm phiếu nhập hàng
20				Sửa phiếu nhập hàng
21				Xóa phiếu nhập hàng
22				Xem phiếu nhập hàng
23			Quản lý phiếu xuất hàng	Thêm phiếu xuất hàng
24				Sửa phiếu xuất hàng
25				Xóa phiếu xuất hàng
26				Xem phiếu xuất hàng
27			Quản lý thuộc tính sản phẩm	Thêm thuộc tính sản phẩm
28				Sửa thuộc tính sản phẩm
29				Xóa thuộc tính sản phẩm
30				Xem thuộc tính sản phẩm
31			Quản lý sku	Thêm sku
32				Sửa sku
33				Xóa sku
34				Xem sku
35			Quản lý imei	Thêm imei
36				Sửa imei
37				Xem imei
38				Xóa imei
39			Xem thống kê nhập hàng	
40			Xem thống kê xuất hàng	
41			Xem thống kê tồn kho	
42		Quản lý	Đăng nhập	
43			Đăng xuất	
44			Quản lý sản phẩm	Thêm sản phẩm
45				Sửa sản phẩm
46				Xóa sản phẩm
47				Xem sản phẩm
48			Quản lý danh mục sản phẩm	Thêm danh mục sản phẩm
49				Sửa danh mục sản phẩm
50				Xóa danh mục sản phẩm
51				Xem danh mục sản phẩm
52			Quản lý hãng sản phẩm	Thêm hãng sản phẩm
53				Sửa hãng sản phẩm
54				Xóa hãng sản phẩm
55				Xem hãng sản phẩm
56			Quản lý nhà cung cấp	Thêm nhà cung cấp
57				Sửa nhà cung cấp
58				Xóa nhà cung cấp
59				Xem nhà cung cấp
60			Quản lý phiếu nhập hàng	Thêm phiếu nhập hàng
61				Sửa phiếu nhập hàng
62				Xóa phiếu nhập hàng
63				Xem phiếu nhập hàng
64				In phiếu nhập hàng
65			Quản lý phiếu xuất hàng	Thêm phiếu xuất hàng
66				Sửa phiếu xuất hàng
67				Xóa phiếu xuất hàng
68				Xem phiếu xuất hàng
69				In phiếu xuất hàng
70			Quản lý thuộc tính sản phẩm	Thêm thuộc tính sản phẩm
71				Sửa thuộc tính sản phẩm
72				Xóa thuộc tính sản phẩm
73				Xem thuộc tính sản phẩm
74			Quản lý sku	Thêm sku
75				Sửa sku
76				Xóa sku
77				Xem sku
78			Quản lý imei	Thêm imei
79				Sửa imei
80				Xóa imei
81				Xem imei
82			Quản lý logs	Xem logs
83			Quản lý tài khoản	Thêm tài khoản
84				Sửa tài khoản
85				Xóa tài khoản
86				Xem tài khoản
87			Xem thống kê nhập hàng	
88			Xem thống kê xuất hàng	
89			Xem thống kê tồn kho	

3.1.3 Kiến trúc tổng quan
Hệ thống được xây dựng dựa trên kiến trúc 3-Tier (Three-Tier Architecture), phân tách rõ ràng giữa các tầng chức năng:
-	Tầng trình bày (UI): Là ứng dụng desktop được xây dựng bằng Java Swing kết hợp FlatLaf 3.7, cung cấp giao diện trực quan để người dùng tương tác với hệ thống. Tầng UI bao gồm 56 file Java, bao gồm các Panel, Dialog và Frame cho từng chức năng.
-	Tầng xử lý nghiệp vụ (BUS): Xử lý logic nghiệp vụ, xác thực dữ liệu đầu vào và điều phối luồng xử lý. Tầng BUS gồm 12 file Java, mỗi file quản lý nghiệp vụ cho một đối tượng cụ thể.
-	Tầng truy cập dữ liệu (DAO): Tương tác trực tiếp với cơ sở dữ liệu MySQL 8.x thông qua JDBC (MySQL Connector/J 8.4.0). Tầng DAO gồm 11 file Java thực hiện các truy vấn SQL.
Ngoài ra, hệ thống sử dụng 14 file DTO (Data Transfer Object) để truyền dữ liệu giữa các tầng và 4 file tiện ích (utils) bao gồm DatabaseHelper, SessionManager, LogHelper và ColorUtil.
 
3.1.4 Quy trình hoạt động
- Biểu đồ Activity Đăng nhập hệ thống:
 
Hình 3.1 Activity – Đăng nhập hệ thống
 
- Biểu đồ Activity Tạo hóa đơn:
 
Hình 3.2 Activity - Tạo hóa đơn
 
-	Biểu đồ Activity Tạo phiếu nhập
 
Hình 3.3 Activity - Tạo phiếu nhập
-	Biểu đồ Activity Quản lý sản phẩm
 
Hình 3.4 Activity – Quản lý sản phẩm
3.1.5 Công nghệ sử dụng
Trong đồ án này, em sử dụng ngôn ngữ lập trình Java (JDK 17+) để xây dựng toàn bộ hệ thống, đảm bảo tính nhất quán và hiệu quả trong việc phát triển ứng dụng. Về phần cơ sở dữ liệu, em sử dụng MySQL 8.x với bộ ký tự utf8mb4, cho phép lưu trữ và truy xuất dữ liệu một cách ổn định và an toàn. Kết nối giữa ứng dụng và cơ sở dữ liệu được thực hiện thông qua JDBC với driver MySQL Connector/J 8.4.0.
Phần giao diện người dùng được xây dựng trên nền tảng Java Swing kết hợp với thư viện FlatLaf 3.7, mang lại giao diện hiện đại, phẳng và thân thiện với người dùng. Kiến trúc phần mềm tuân theo mô hình 3-Tier (UI → BUS → DAO), đảm bảo tính phân tách rõ ràng giữa các tầng chức năng.
Ngoài ra, hệ thống áp dụng các mẫu thiết kế phổ biến bao gồm Singleton Pattern cho quản lý kết nối và phiên, DAO Pattern cho truy cập dữ liệu, Template Method Pattern cho các màn hình CRUD và CardLayout Pattern cho điều hướng giữa các panel trong MainFrame.
3.2 Thiết kế hệ thống
3.2.1 Thiết kế cơ sở dữ liệu
Bảng 3.2 Bảng accounts
STT	THUỘC TÍNH	KIỂU DỮ LIỆU	KHOÁ	MÔ TẢ
1	id	int	PK	id của tài khoản
2	username	varchar(32)		tài khoản
3	password	varchar(255)		mật khẩu
4	role	enum (admin, staff)		vai trò (admin, nhân viên)
5	fullname	varchar(32)		tên nhân viên
6	last_login	datetime		lần đăng nhập gần nhất
7	created_at	datetime		được tạo vào thời gian nào
Bảng 3.3 Bảng categories
STT	THUỘC TÍNH	KIỂU DỮ LIỆU	KHOÁ	MÔ TẢ
1	id	int	PK	mã danh mục sản phẩm
2	name	varchar(50)		tên danh mục sản phẩm (điện thoại, cáp sạc, sạc dự phòng,…)
3	is_deleted	boolen		đã xóa (ẩn)
Bảng 3.4 Bảng brands
STT	THUỘC TÍNH	KIỂU DỮ LIỆU	KHOÁ	MÔ TẢ
1	id	int	PK	id hãng
2	name	varchar(50)		tên hãng
3	is_deleted	boolen		đã xóa (ẩn)
Bảng 3.5 Bảng products
STT	THUỘC TÍNH	KIỂU DỮ LIỆU	KHOÁ	MÔ TẢ
1	id	int	PK	id sản phẩm
2	brand_id	int	FK	id hãng
3	name	varchar(255)		tên sản phẩm
4	category_id	int	FK	danh mục sản phẩm (điện thoại, dây sạc, sạc dự phòng,…)
5	created_at	datetime		được tạo vào
6	is_deleted	boolen		đã xóa (ẩn)

Bảng 3.6 Bảng attributes
STT	THUỘC TÍNH	KIỂU DỮ LIỆU	KHOÁ	MÔ TẢ
1	id	int	PK	mã thuộc tính
2	name	varchar(50)		tên thuộc tính (ram, dung lượng, màu sắc,…)

Bảng 3.7 Bảng attribute_options
STT	THUỘC TÍNH	KIỂU DỮ LIỆU	KHOÁ	MÔ TẢ
1	id	int	PK	mã giá trị thuộc tính
2	attribute_id	int	FK	mã thuộc tính
3	value	varchar(50)		giá tri của thuộc tính (đỏ, cam, 8gb, dài 2m,…)

Bảng 3.8 Bảng skus
STT	THUỘC TÍNH	KIỂU DỮ LIỆU	KHOÁ	MÔ TẢ
1	id	int	PK	id của sku
2	product_id	int	FK	mã sản phẩm
3	code	varchar(25)	FK	mã sku (vd IP17PM-CAM-512 là ip17 promax cam 512gb)
4	price	double		giá sản phẩm
5	stock	int		số lượng tồn kho tổng quát
 
Bảng 3.9 Bảng attribute_option_sku
STT	THUỘC TÍNH	KIỂU DỮ LIỆU	KHOÁ	MÔ TẢ
1	sku_id	int	PK, FK	mã sku
2	attribute_option_id	int	PK, FK	mã giá trị thuộc tính

Bảng 3.10 Bảng phone_imeis
STT	THUỘC TÍNH	KIỂU DỮ LIỆU	KHOÁ	MÔ TẢ
1	id	int	PK	mã của imei
2	sku_id	int	FK	mã sku
3	import_receipt_id	int	FK	mã phiếu nhập đã nhập hàng imei này
4	imei	varchar(50)		mã imei
5	status	enum		trạng thái (còn hàng, đã bán, bảo hành, hỏng)
6	created_at	datetime		thời gian nhập vào kho

Bảng 3.11 Bảng suppliers
STT	THUỘC TÍNH	KIỂU DỮ LIỆU	KHOÁ	MÔ TẢ
1	id	int	PK	id nhà cung cấp
2	name	varchar(50)		tên nhà cung cấp

 
Bảng 3.12 Bảng import_receipts
STT	THUỘC TÍNH	KIỂU DỮ LIỆU	KHOÁ	MÔ TẢ
1	id	int	PK	mã phiếu nhập hàng
2	supplier_id	int	FK	nhà cung cấp
3	staff_id	int	FK	người lập phiếu nhập hàng
4	total_amount	double	 	tổng số tiền nhập hàng
5	created_at	datetime	 	thời gian lập phiếu nhập hàng

Bảng 3.13 Bảng import_details
STT	THUỘC TÍNH	KIỂU DỮ LIỆU	KHOÁ	MÔ TẢ
1	id	int	PK	mã chi tiết phiếu nhập hàng
2	import_receipt_id	int	FK	mã phiếu nhập hàng
3	product_id	int	FK	mã sản phẩm nhập
4	sku_id	int	FK	mã sku
5	quantity	int		số lượng

Bảng 3.14 Bảng invoices
STT	THUỘC TÍNH	KIỂU DỮ LIỆU	KHOÁ	MÔ TẢ
1	id	int	PK	mã phiếu xuất hàng
2	staff_id	int	FK	người lập phiếu xuất hàng
3	total_amount	double		tổng số tiền xuất hàng
4	created_at	datetime		thời gian lập phiếu xuất hàng

 
Bảng 3.15 Bảng invoice_details
STT	THUỘC TÍNH	KIỂU DỮ LIỆU	KHOÁ	MÔ TẢ
1	id	int	PK	mã chi tiết phiếu xuất hàng
2	invoice_id	int	FK	mã phiếu xuất hàng
3	sku_id	int	FK	mã sku
4	quantity	int		số lượng (mặc định 1 nếu là điện thoại)
5	imei_id	int	FK	mã imei (nếu là điện thoại không thì null)

Bảng 3.16 Bảng suppliers
STT	THUỘC TÍNH	KIỂU DỮ LIỆU	KHOÁ	MÔ TẢ
1	id	int	PK	mã nhà cung cấp
2	name	varchar(50)		tên nhà cung cấp
3	phone	varchar(20)		số điện thoại nhà cung cấp
4	email	varchar(100)		email nhà cung cấp
5	address	varchar(255)		địa chỉ nhà cung cấp

Bảng 3.17 Bảng category_attribute
STT	THUỘC TÍNH	KIỂU DỮ LIỆU	KHOÁ	MÔ TẢ
1	category_id	int	PK, FK	mã danh mục
2	attribute_id	int	PK, FK	mã thuộc tính

 
Bảng 3.18 Bảng logs
STT	THUỘC TÍNH	KIỂU DỮ LIỆU	KHOÁ	MÔ TẢ
1	id	int	PK	mã logs
2	user_id	int	FK	mã người dùng
3	action	varchar(50)		hành động
4	details	varchar(500)		chi tiết hành động
5	created_at	datetime		được tạo vào thời điểm

  
3.2.2 Thiết kế sơ đồ lớp
 
Hình 3.5 Sơ đồ lớp
3.2.3 Mô hình ERD
 
Hình 3.6 Sơ đồ ERD tổng quát. 
 
3.2.4 Thiết kế chức năng
Sơ đồ Use Case tổng quát:
 
Hình 3.7 Sơ đồ Use Case tổng quát.
 
+	 Đặc tả Use Case Đăng nhập:
Bảng 3.19 Bảng đặc tả Use Case Đăng nhập
Tên Use Case	Đăng nhập hệ thống
Mô tả	Người dùng đăng nhập vào hệ thống bằng cách nhập username và password
Tác nhân (Actor)	Admin, Staff
Tiền điều kiện	- Người dùng chưa đăng nhập.
- Tài khoản phải tồn tại trong hệ thống.
Luồng sự kiện	1.	Người dùng mở ứng dụng.
2.	Hệ thống hiển thị màn hình đăng nhập.
3.	Người dùng nhập username và password.
4.	Người dùng nhấn “Đăng nhập”.
5.	Hệ thống xác thực thông tin.
6.	Hệ thống cập nhật last_login.
7.	Hệ thống lưu session.
8.	Hệ thống ghi log “Đăng nhập”.
9.	Hệ thống mở MainFrame với Dashboard.
Hậu điều kiện	- Người dùng đăng nhập thành công.
- Session được tạo.
- Log đăng nhập được ghi nhận.
Ngoại lệ	1. Thiếu thông tin: Hệ thống báo lỗi, quay lại bước 3.
2. Tài khoản không tồn tại: Hệ thống báo lỗi, quay lại bước 3.
3. Mật khẩu sai: Hệ thống báo lỗi, quay lại bước 3.
+	 Đặc tả Use Case Quản lý phiếu nhập kho:
Bảng 3.20 Bảng đặc tả Use Case Quản lý phiếu nhập kho
Tên Use Case	Quản lý phiếu nhập kho
Mô tả	Quản lý các phiếu nhập hàng từ nhà cung cấp
Tác nhân (Actor)	Admin, Staff
Tiền điều kiện	Người dùng đã đăng nhập
Luồng sự kiện	1.	Chọn menu “Nhập kho”.
2.	Hiển thị danh sách phiếu nhập.
3.	Chọn hành động (Thêm/sửa/xóa/xem).
4.	Thực hiện thao tác Thêm/sửa/xóa/xem tương ứng.
Hậu điều kiện	Phiếu nhập được tạo/sửa/xóa thành công, stock được cập nhật.
Ngoại lệ	- Thông tin nhập không đầy đủ: Hệ thống hiển thị thông báo lỗi.
+	 Đặc tả Use Case Tạo phiếu nhập:
Bảng 3.21 Bảng đặc tả Use Case Tạo phiếu nhập
Tên Use Case	Tạo phiếu nhập kho
Mô tả	Tạo phiếu nhập hàng mới từ nhà cung cấp.
Tác nhân (Actor)	Admin, Staff
Tiền điều kiện	- Người dùng đã đăng nhập.
- Có ít nhất 1 nhà cung cấp trong hệ thống.
Luồng sự kiện	1. Nhấn “Thêm phiếu nhập”.
2. Hệ thống hiển thị form.
3. Chọn nhà cung cấp.
4. Chọn sản phẩm và SKU.
5. Nhập số lượng.
6. (Nếu là ĐT) Nhập danh sách IMEI.
7. Thêm vào chi tiết (Lặp lại 4-7 nếu cần).
8. Hệ thống tính tổng tiền.
9. Xác nhận.
10. Tạo import_receipt -> Tạo import_details -> Cập nhật stock (tăng) -> Tạo phone_imeis -> Ghi log -> Hiển thị "Thành công".
Hậu điều kiện	- Phiếu nhập được tạo.
- Stock của SKU tăng.
- IMEI được tạo (nếu là điện thoại).
- Log được ghi nhận.
Ngoại lệ	1. Số IMEI không khớp số lượng: Cảnh báo, quay lại bước 6.
2. IMEI đã tồn tại: Báo lỗi, nhập IMEI khác.
+	Đặc tả Use Case Quản lý phiếu xuất:
Bảng 3.22 Bảng đặc tả Use Case Quản lý phiếu xuất
Tên Use Case	Quản lý phiếu xuất (hóa đơn bán hàng)
Mô tả	Quản lý các hóa đơn bán hàng cho khách.
Tác nhân (Actor)	Admin, Staff
Tiền điều kiện	Người dùng đã đăng nhập.
Luồng sự kiện	1.	Chọn menu “Xuất kho”.
2.	Hiển thị danh sách phiếu xuất.
3.	Chọn hành động (Thêm/sửa/xóa/xem).
4.	Thực hiện thao tác Thêm/sửa/xóa/xem tương ứng.
Hậu điều kiện	Hóa đơn được tạo/xóa, stock giảm, IMEI status cập nhật.
Ngoại lệ	Không có.
+	 Đặc tả Use Case Tạo hóa đơn bán hàng:
Bảng 3.23 Bảng đặc tả Use Case Tạo hóa đơn bán hàng
Tên Use Case	Tạo hóa đơn bán hàng
Mô tả	Tạo hóa đơn bán hàng cho khách hàng.
Tác nhân (Actor)	Admin, Staff
Tiền điều kiện	- Người dùng đã đăng nhập.
- Có sản phẩm trong kho (stock > 0).
Luồng sự kiện	1. Nhấn “Thêm hóa đơn”.
2. Hiển thị form.
3. Chọn SKU.
4. Nhập số lượng.
5. Hệ thống kiểm tra stock.
6. (Nếu là ĐT) Chọn IMEI available.
7. Thêm vào chi tiết (Lặp lại 3-7).
8. Tính tổng tiền -> Xác nhận.
9. Tạo invoice -> Tạo invoice_details -> Giảm stock -> Cập nhật IMEI status -> Ghi log -> Thành công.
Hậu điều kiện	- Hóa đơn được tạo.
- Stock của SKU giảm.
Ngoại lệ	1. Số lượng > stock: Báo “Không đủ hàng”.
2. Không có IMEI khả dụng: Báo “Hết hàng”.

+	 Đặc tả Use Case Quản lý sản phẩm:
Bảng 3.24 Bảng đặc tả Use Case Quản lý sản phẩm
Tên Use Case	Quản lý sản phẩm
Mô tả	Quản lý thông tin sản phẩm (CRUD).
Tác nhân (Actor)	Admin, Staff
Tiền điều kiện	Người dùng đã đăng nhập.
Luồng sự kiện	1.	Chọn menu “Sản phẩm”.
2.	Hiển thị danh sách sản phẩm.
3.	Chọn hành động (Thêm/sửa/xóa/xem).
4.	Thực hiện thao tác Thêm/sửa/xóa/xem tương ứng.
Hậu điều kiện	Sản phẩm được thêm/sửa/xóa, log được ghi.
Ngoại lệ	- Nhập sai thông tin: Hệ thống hiển thị thông báo lỗi.
+	 Đặc tả Use Case Quản lý tài khoản:
Bảng 3.25 Bảng đặc tả Use Case Nhắn tin nhóm
Tên Use Case	Quản lý tài khoản
Mô tả	Quản lý tài khoản người dùng
Tác nhân (Actor)	Admin.
Tiền điều kiện	Người dùng đã đăng nhập và là Admin.
Luồng sự kiện	1. Admin chọn menu “Tài khoản”.
2. Hiển thị danh sách tài khoản.
3. Chọn hành động (Thêm/Sửa/Xóa/Phân quyền).
4. Thực hiện hành động tương ứng.
Hậu điều kiện	Tài khoản được tạo/sửa/xóa, log được ghi.
Ngoại lệ	Không có.
+	 Đặc tả Use Case Xem thống kê:
Bảng 3.26 Bảng đặc tả Use Case Xem thống kê chi tiết
Tên Use Case	Xem thống kê chi tiết.
Mô tả	Xem các báo cáo thống kê về doanh thu, sản phẩm bán chạy, tồn kho.
Tác nhân (Actor)	Admin, Staff
Tiền điều kiện	Người dùng đã đăng nhập.
Luồng sự kiện	1. Chọn menu “Thống kê”.
2. Hiển thị trang thống kê.
3. Chọn khoảng thời gian.
4. Hệ thống tính toán và hiển thị (Doanh thu, Top bán chạy, Tồn kho, Biểu đồ).
Hậu điều kiện	Hiển thị các báo cáo thống kê.
Ngoại lệ	Không có.
 
 
3.2.5 Thiết kế kiến trúc hệ thống
Hệ thống Quản lý Kho Điện Thoại được thiết kế theo mô hình kiến trúc 3 tầng (Three-Tier Architecture), phân tách rõ ràng giữa giao diện người dùng, xử lý nghiệp vụ và truy cập dữ liệu. Kiến trúc này đảm bảo tính bảo trì, mở rộng và tái sử dụng mã nguồn cao.
Hệ thống bao gồm ba thành phần chính:
-	Ứng dụng Desktop (Client): Được xây dựng bằng Java Swing kết hợp FlatLaf 3.7, sử dụng CardLayout để chuyển đổi giữa 13 panel chức năng. Ứng dụng khởi động từ LoginFrame, sau khi xác thực thành công sẽ chuyển sang MainFrame với sidebar điều hướng và vùng nội dung chính.
-	Tầng xử lý nghiệp vụ (BUS): 12 lớp BUS xử lý logic nghiệp vụ, xác thực dữ liệu đầu vào trước khi chuyển đến tầng DAO. Mỗi lớp BUS tương ứng với một đối tượng quản lý trong hệ thống (ProductBUS, SkuBUS, ImeiBUS, ImportReceiptBUS, InvoiceBUS, AccountBUS, v.v.).
-	Cơ sở dữ liệu MySQL: Lưu trữ dữ liệu có cấu trúc trong 16 bảng quan hệ, bao gồm thông tin sản phẩm, biến thể, IMEI, phiếu nhập/xuất, tài khoản và nhật ký. Kết nối được quản lý qua DatabaseHelper (Singleton) với cấu hình từ file config.properties.
Giao tiếp giữa các tầng tuân theo luồng một chiều: UI → BUS → DAO → MySQL. Tầng UI gọi các phương thức trong BUS, BUS xác thực dữ liệu và gọi DAO, DAO thực hiện truy vấn SQL thông qua JDBC và trả về kết quả qua DTO. Kiến trúc này cho phép thay đổi giao diện, logic nghiệp vụ hoặc cơ sở dữ liệu một cách độc lập mà không ảnh hưởng đến các tầng khác.
3.2.6 Thiết kế phân quyền và bảo mật
Phân quyền và bảo mật là yếu tố quan trọng trong hệ thống quản lý kho hàng. Hệ thống được thiết kế với cơ chế phân quyền vai trò (Role-Based Access Control) và các biện pháp bảo vệ dữ liệu cơ bản.
Phân quyền vai trò:
-	Quản trị viên (Admin): Toàn quyền truy cập tất cả 13 module chức năng, bao gồm quản lý tài khoản người dùng và xem nhật ký hoạt động hệ thống.
-	Nhân viên (Staff): Truy cập các module nghiệp vụ gồm: Dashboard, Sản phẩm, Thuộc tính, SKU, IMEI, Nhập kho, Xuất kho, Nhà cung cấp, Thương hiệu, Danh mục và Thống kê. Không có quyền truy cập module Tài khoản và Nhật ký.
-	Kiểm tra phân quyền: Lớp SessionManager lưu trữ thông tin phiên đăng nhập và cung cấp phương thức isAdmin() để kiểm tra vai trò. MainFrame ẩn các menu item "Tài khoản" và "Logs" đối với tài khoản Staff.
Quản lý phiên đăng nhập:
-	SessionManager (Singleton): Quản lý phiên đăng nhập duy nhất của người dùng, lưu trữ đối tượng AccountDTO chứa thông tin tài khoản đang đăng nhập.
-	Ghi log hoạt động: Lớp LogHelper ghi lại toàn bộ hoạt động trong hệ thống bao gồm đăng nhập, đăng xuất, thêm/sửa/xóa dữ liệu, tạo phiếu nhập và phiếu xuất, giúp quản trị viên theo dõi và kiểm soát.
Bảo vệ dữ liệu:
-	Soft Delete: Sản phẩm, thương hiệu và danh mục sử dụng cơ chế xóa mềm (soft delete) thông qua cờ is_deleted, tránh mất dữ liệu quan trọng và đảm bảo tính toàn vẹn tham chiếu.
-	Foreign Key Constraints: Cơ sở dữ liệu sử dụng ràng buộc khóa ngoại (Foreign Key) với các hành động ON DELETE CASCADE hoặc RESTRICT để đảm bảo tính toàn vẹn dữ liệu giữa các bảng.
-	Check Constraints: Ràng buộc kiểm tra (CHECK) đảm bảo tính hợp lệ của dữ liệu, ví dụ số lượng nhập phải lớn hơn 0.
-	PreparedStatement: Tất cả truy vấn SQL sử dụng PreparedStatement với tham số hóa, ngăn chặn hiệu quả tấn công SQL Injection.
Xác thực dữ liệu:
-	Tầng BUS thực hiện xác thực dữ liệu đầu vào trước khi chuyển đến DAO, bao gồm kiểm tra null, kiểm tra rỗng, kiểm tra giá trị ID hợp lệ và kiểm tra trùng lặp.
-	Tầng UI hiển thị thông báo lỗi rõ ràng khi người dùng nhập dữ liệu không hợp lệ thông qua JOptionPane.
 
CHƯƠNG 4
GIAO DIỆN HỆ THỐNG
4.1 Giao diện đăng nhập
 
Hình 4.1 Giao diện đăng nhập
4.2 Giao diện dashboard
 
Hình 4.2 Giao diện dashboard
4.3 Giao diện menu sản phẩm
 
Hình 4.3 Giao diện menu sản phẩm
4.4 Giao diện menu thuộc tính
 
Hình 4.4 Giao diện menu thuộc tính
4.5 Giao diện menu SKU
 
Hình 4.5 Giao diện menu SKU
 
4.6 Giao diện menu IMEI
 
Hình 4.6 Giao diện menu IMEI
4.7 Giao diện menu nhập kho
 
Hình 4.7 Giao diện menu nhập kho
4.8 Giao diện menu xuất kho
 
Hình 4.8 Giao diện menu xuất kho
4.9 Giao diện menu nhà cung cấp
 
Hình 4.9 Giao diện menu nhà cung cấp
4.10 Giao diện menu thương hiệu
 
Hình 4.10 Giao diện menu thương hiệu
4.11 Giao diện menu danh mục sản phẩm
 
Hình 4.11 Giao diện menu danh mục sản phẩm
4.12 Giao diện menu tài khoản
 
Hình 4.12 Giao diện menu tài khoản
4.13 Giao diện menu thống kê
 
Hình 4.13 Giao diện menu thống kê
4.14 Giao diện menu logs
 
Hình 4.14 Giao diện menu logs
 
CHƯƠNG 5
KẾT LUẬN
5.1 Kết luận
Đồ án "Phát triển phần mềm quản lý kho điện thoại" đã được phát triển thành công với đầy đủ các mục tiêu đề ra ban đầu. Qua quá trình phân tích, thiết kế, triển khai và kiểm thử, nhóm đã xây dựng được một ứng dụng quản lý kho hàng hoàn chỉnh với kiến trúc 3-Tier rõ ràng và giao diện hiện đại.
Về mặt kiến trúc, dự án đã được tổ chức thành các tầng rõ ràng:
-	Tầng UI: Xây dựng bằng Java Swing kết hợp FlatLaf 3.7, gồm 56 file Java cung cấp giao diện trực quan với 13 module chức năng, sử dụng CardLayout cho điều hướng và BaseCrudPanel (Template Method) cho các màn hình CRUD.
-	Tầng BUS: 12 file Java xử lý logic nghiệp vụ và xác thực dữ liệu.
-	Tầng DAO: 11 file Java thực hiện truy vấn SQL thông qua JDBC với PreparedStatement.
-	DTO: 14 file Java đóng vai trò truyền dữ liệu giữa các tầng.
Về mặt tính năng, dự án đã đáp ứng được các yêu cầu quản lý kho hàng điện thoại:
-	Quản lý sản phẩm với phân loại theo thương hiệu và danh mục, hỗ trợ soft delete.
-	Quản lý biến thể sản phẩm (SKU) với hệ thống thuộc tính động theo danh mục.
-	Theo dõi mã IMEI thiết bị với 4 trạng thái (available, sold, warranty, defective).
-	Nhập kho từ nhà cung cấp với tự động cập nhật tồn kho và ghi nhận IMEI.
-	Xuất kho bán hàng với tự động giảm tồn kho và cập nhật trạng thái IMEI.
-	Phân quyền Admin/Staff với ghi nhật ký hoạt động đầy đủ.
-	Dashboard thống kê tổng quan và biểu đồ doanh thu.
-	Thống kê doanh thu, lợi nhuận, top sản phẩm bán chạy và cảnh báo tồn kho thấp.
Về mặt cơ sở dữ liệu, hệ thống được thiết kế với 16 bảng quan hệ, sử dụng foreign key constraints để đảm bảo tính toàn vẹn dữ liệu, hỗ trợ bộ ký tự utf8mb4 cho tiếng Việt. Cấu trúc dữ liệu hỗ trợ đầy đủ các tính năng đã triển khai và sẵn sàng cho việc mở rộng trong tương lai.
5.2 Hạn chế
Mặc dù dự án đã đạt được các mục tiêu đề ra, vẫn còn một số hạn chế cần được cải thiện:
-	Bảo mật mật khẩu: Mật khẩu hiện tại được lưu dạng plaintext trong cơ sở dữ liệu, chưa được mã hóa bằng các thuật toán băm an toàn như BCrypt hoặc SHA-256.
-	Quản lý kết nối: Hệ thống sử dụng single connection thông qua Singleton DatabaseHelper, chưa áp dụng connection pooling (như HikariCP) để tối ưu hiệu suất khi có nhiều thao tác đồng thời.
-	Quản lý giao dịch: Chưa triển khai transaction management cho các thao tác nhập/xuất kho phức tạp, có thể gây mất nhất quán dữ liệu khi xảy ra lỗi giữa chừng.
-	Kiểm thử: Chưa có unit tests tự động để kiểm thử các lớp BUS và DAO, việc kiểm thử chủ yếu được thực hiện thủ công.
-	Hỗ trợ nền tảng: Mặc dù Java hỗ trợ đa nền tảng, ứng dụng chưa được kiểm thử đầy đủ trên các hệ điều hành khác ngoài Windows.
5.3 Hướng phát triển
Dựa trên nền tảng đã xây dựng và các hạn chế hiện tại, đồ án của em có nhiều hướng phát triển tiềm năng:
-	Mã hóa mật khẩu: Triển khai mã hóa mật khẩu bằng BCrypt trước khi lưu vào cơ sở dữ liệu để tăng cường bảo mật.
-	Connection Pooling: Tích hợp HikariCP hoặc các thư viện connection pooling khác để tối ưu hiệu suất kết nối cơ sở dữ liệu.
-	Transaction Management: Triển khai quản lý giao dịch cho các thao tác nhập/xuất kho phức tạp, đảm bảo tính atomicity.
-	Xuất báo cáo: Bổ sung chức năng xuất báo cáo thống kê sang định dạng PDF hoặc Excel để hỗ trợ quản lý.
-	Quản lý bảo hành: Phát triển module quản lý bảo hành thiết bị, theo dõi thời gian bảo hành và lịch sử sửa chữa.
-	Mã vạch/QR Code: Tích hợp chức năng quét mã vạch hoặc QR Code để nhập IMEI và tìm kiếm sản phẩm nhanh hơn.
-	Phiên bản Web: Phát triển phiên bản web của ứng dụng để hỗ trợ truy cập từ xa và quản lý nhiều chi nhánh.
-	Unit Testing: Bổ sung unit tests với JUnit để kiểm thử tự động các lớp BUS và DAO.
 
TÀI LIỆU THAM KHẢO
Đặng Quốc Bảo (Chủ biên) (2020), Giáo trình cơ sở dữ liệu. Nhà xuất bản Đại học Cần Thơ, Cần Thơ. 154 trang.
Horstmann, C. S. (2018), Core Java Volume I – Fundamentals. Prentice Hall, 11th Edition. 928 trang.
Oracle (2024), Java SE Documentation. https://docs.oracle.com/en/java/, accessed on 15/1/2026.
Oracle (2024), MySQL 8.0 Reference Manual. https://dev.mysql.com/doc/refman/8.0/en/, accessed on 15/1/2026.
Oracle (2024), JDBC Overview. https://docs.oracle.com/javase/tutorial/jdbc/, accessed on 20/1/2026.
FormDev (2025), FlatLaf – Flat Look and Feel for Java Swing. https://www.formdev.com/flatlaf/, accessed on 20/1/2026.
Gamma, E., Helm, R., Johnson, R., Vlissides, J. (1994), Design Patterns: Elements of Reusable Object-Oriented Software. Addison-Wesley Professional. 395 trang.
