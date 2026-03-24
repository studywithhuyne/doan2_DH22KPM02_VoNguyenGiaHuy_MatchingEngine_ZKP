# Vì Sao Dùng Svelte Thay Vì ReactJS / NextJS

Tài liệu này giải thích lý do dự án chọn Svelte cho frontend, cách nó phù hợp với kiến trúc hiện tại, và điểm mạnh / điểm yếu của nó khi so với ReactJS và NextJS.

## 1. Bối cảnh lựa chọn framework

Frontend của dự án là một **SPA giao dịch thời gian thực**:
- cần cập nhật orderbook qua WebSocket,
- cần phản hồi nhanh khi user đổi route hoặc đặt lệnh,
- cần hiển thị trạng thái auth, trade history, asset data, và ZK verify,
- không cần SSR cho SEO hay content marketing.

Trong bối cảnh đó, Svelte là lựa chọn hợp lý hơn ReactJS hoặc NextJS vì nó cho một UI nhẹ, ít boilerplate, và phù hợp với mô hình terminal-style trading app.

## 2. Svelte đang được dùng như thế nào trong dự án

Trong `web/` dự án dùng:
- Svelte 5,
- Vite,
- SPA thuần,
- không dùng SvelteKit.

File [web/src/App.svelte](web/src/App.svelte) cho thấy cách tổ chức ứng dụng:
- `onMount` để kết nối orderbook WebSocket và bootstrap auth,
- `onDestroy` để ngắt kết nối,
- store-driven navigation bằng `router`, `authState`, `adminAuthState`,
- render theo route bằng logic điều kiện đơn giản.

Nói cách khác, Svelte đang đóng vai trò là lớp giao diện nhẹ, còn phần nghiệp vụ nặng nằm ở backend Rust.

## 3. Vì sao chọn Svelte thay vì ReactJS

### 3.1 Ít boilerplate hơn

React thường yêu cầu nhiều lớp phụ trợ hơn cho cùng một UI:
- component,
- hook,
- state management,
- memoization,
- effect management,
- routing library.

Svelte cho phép viết UI gần với HTML/CSS/TS hơn, nên code ngắn hơn và dễ đọc hơn khi ứng dụng chủ yếu là dashboard giao dịch.

### 3.2 Re-render tự động ở mức compile-time

React dùng Virtual DOM và cơ chế render lại theo tree. Svelte compile component thành JavaScript tối ưu trước khi chạy, nên thường có ít overhead hơn ở UI có nhiều update nhỏ như:
- orderbook ticks,
- trade feed,
- state auth,
- số liệu live từ WebSocket.

Trong app giao dịch, những thay đổi nhỏ nhưng liên tục là chuyện bình thường. Svelte xử lý kiểu đó rất tự nhiên.

### 3.3 Dễ ghép với stores và stream dữ liệu

Dự án có các store như:
- `orderBookStore`,
- `routerStore`,
- `authStore`,
- `adminAuthStore`.

Mô hình store của Svelte khá phù hợp với dữ liệu live từ WebSocket vì:
- nguồn dữ liệu tập trung,
- component chỉ subscribe dữ liệu cần thiết,
- ít phải truyền props qua nhiều tầng.

### 3.4 Phù hợp với UI “terminal” và dashboard

Giao diện sàn giao dịch thường cần:
- bảng dữ liệu,
- panel trạng thái,
- danh sách thay đổi liên tục,
- visual density cao.

Svelte rất hợp với kiểu UI này vì nó không ép người viết phải theo một mô hình quá nặng như một số pattern trong React ecosystem.

### 3.5 Đơn giản hóa việc kiểm soát trạng thái local

Trong app hiện tại, routing và auth đều có tính local và event-driven. Svelte giúp tổ chức phần này gọn hơn mà không cần setup framework cấp ứng dụng quá phức tạp.

## 4. Điểm mạnh của Svelte so với ReactJS

### 4.1 Runtime nhẹ hơn

Svelte không mang theo cùng mức runtime orchestration như React. Điều này có lợi cho:
- bundle size,
- thời gian bootstrap,
- cảm giác UI phản hồi nhanh.

### 4.2 Cú pháp ngắn gọn hơn

Các mẫu code như:
- phản ứng theo store,
- cập nhật giao diện theo state,
- mount / destroy,
thường ngắn hơn đáng kể so với React tương đương.

### 4.3 Ít phụ thuộc vào thư viện ngoài hơn

Nhiều ứng dụng React hiện cần thêm routing, state, effect helpers, form helpers, memoization strategy. Svelte cho nhiều thứ sẵn trong core, nên giảm số quyết định kỹ thuật phụ.

### 4.4 Phù hợp cho đội muốn “ship nhanh nhưng gọn”

Khi frontend không phải lõi của sản phẩm mà chỉ là lớp hiển thị cho engine Rust, Svelte giúp tập trung vào tính năng thay vì quản trị framework phức tạp.

## 5. Điểm yếu của Svelte so với ReactJS

### 5.1 Ecosystem nhỏ hơn

React có hệ sinh thái rất lớn:
- component libraries,
- form libraries,
- testing utilities,
- enterprise patterns,
- community support.

Svelte nhỏ hơn về quy mô thư viện và mức độ phổ biến.

### 5.2 Nguồn nhân lực ít hơn

Tìm developer quen React dễ hơn. Điều này quan trọng nếu dự án phải mở rộng team nhanh.

### 5.3 Một số pattern enterprise chưa phổ biến bằng React

React có rất nhiều pattern đã được chuẩn hóa qua thời gian. Svelte vẫn đủ tốt, nhưng ecosystem enterprise-style có thể không phong phú bằng.

### 5.4 Tài nguyên học tập và ví dụ thực chiến ít hơn

Nếu gặp bài toán rất đặc thù, React thường có nhiều câu trả lời sẵn hơn Svelte.

## 6. Vì sao không chọn NextJS

NextJS mạnh khi dự án cần:
- SSR,
- SSG,
- SEO,
- hybrid rendering,
- full-stack React framework,
- file-based routing lớn.

Nhưng dự án này là một **sàn giao dịch SPA** với đặc điểm:
- user đã đăng nhập,
- nội dung động liên tục,
- dữ liệu phụ thuộc vào WebSocket và API,
- gần như không cần SEO.

Vì vậy NextJS sẽ mang thêm nhiều lớp không cần thiết.

### 6.1 SSR không phải nhu cầu chính

Trang trading, orderbook, trade history, asset dashboard đều là dữ liệu sau đăng nhập. SSR ở đây không tạo ra giá trị lớn như với website marketing hoặc content publishing.

### 6.2 NextJS có thêm độ phức tạp kiến trúc

NextJS thường kéo theo:
- server/client boundary,
- server actions hoặc data fetching conventions,
- routing conventions riêng,
- hydration considerations,
- deployment pattern nặng hơn SPA thuần.

Trong khi dự án chỉ cần một frontend nhẹ nối với backend Rust thì NextJS là quá tay.

### 6.3 SPA với Vite đơn giản hơn cho use case này

Với app này, build SPA bằng Vite:
- deploy nhanh,
- dễ containerize cùng Nginx,
- dễ phục vụ static assets,
- dễ ghép WebSocket và REST API.

## 7. Điểm mạnh của Svelte so với NextJS

### 7.1 Ít tầng phức tạp hơn

Svelte SPA tập trung đúng vào UI client-side, không kéo theo toàn bộ hybrid rendering stack.

### 7.2 Hợp với WebSocket realtime

NextJS vẫn làm realtime được, nhưng Svelte SPA tự nhiên hơn khi UI phụ thuộc nhiều vào dữ liệu stream liên tục.

### 7.3 Deployment gọn hơn

Svelte build ra static assets, có thể phục vụ qua Nginx. Điều này phù hợp với kiến trúc Docker + Nginx của dự án.

## 8. Điểm yếu của Svelte so với NextJS

### 8.1 Không có SSR/SSG tích hợp sẵn như NextJS

Nếu dự án cần SEO hoặc pre-render mạnh thì Svelte SPA không phải lựa chọn tốt bằng NextJS.

### 8.2 Không có full-stack framework mặc định

NextJS cung cấp nhiều tiện ích full-stack từ một framework duy nhất. Svelte SPA thì không.

### 8.3 Routing và conventions ít “chuẩn hóa” hơn

NextJS có convention mạnh về file-based routing và kiến trúc app. Svelte SPA linh hoạt hơn nhưng cũng đòi hỏi tự tổ chức nhiều hơn.

## 9. Tại sao Svelte phù hợp nhất với dự án này

Svelte phù hợp vì dự án có các đặc điểm sau:
- là một dashboard giao dịch chứ không phải website content,
- cần realtime cập nhật orderbook,
- chủ yếu là client-side interaction sau khi đăng nhập,
- backend Rust đã xử lý toàn bộ nghiệp vụ nặng,
- frontend chỉ làm nhiệm vụ render và điều phối luồng user.

Điều đó làm cho Svelte trở thành lựa chọn cân bằng nhất giữa:
- hiệu năng,
- độ gọn của code,
- tính dễ bảo trì,
- và mức độ phức tạp kiến trúc.

## 10. Kết luận

Nếu so theo đúng ngữ cảnh của dự án này:

- **Svelte**: phù hợp nhất cho SPA realtime, ít boilerplate, nhẹ, dễ ghép WebSocket, triển khai gọn.
- **ReactJS**: mạnh về ecosystem và thị trường nhân lực, nhưng nặng hơn về boilerplate và orchestration cho use case này.
- **NextJS**: mạnh nếu cần SSR/SEO/full-stack React, nhưng trong dự án này lại tạo thêm độ phức tạp không cần thiết.

Nói ngắn gọn: **Svelte được chọn không phải vì nó “tốt hơn tuyệt đối”, mà vì nó phù hợp hơn với mục tiêu của hệ thống**.

