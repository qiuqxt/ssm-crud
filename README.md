项目描述：SSM整合案例，使用浏览器请求访问，来对资源进行CRUD。

# 功能点

 1. 分页
 2. 数据校验
 		- jquery前端校验+JSR303后端校验
  3. ajax
  4. Rest风格的URI；使用HTTP协议请求方式的动词，来表示对资源的操作（GET（查询），POST（新增），PUT（修改），DELETE（删除））

---
# 技术点
1. 基础框架-ssm（SpringMVC+Spring+MyBatis）
2. 数据库-MySQL
3. 前端框架-bootstrap快速搭建简洁美观的界面
4. 项目的依赖管理-Maven
5. 分页-pagehelper
6. 逆向工程-MyBatis Generator

---
# 基础环境搭建
1. 创建maven工程
2. 引入项目依赖的jar包
    - spring
    - springmvc
    - mybatis
    - 数据库连接池，驱动包
    - 其他（jstl，servlet-api，junit）
3. 引入bootstrap前端框架
4. 编写ssm整合的关键配置文件
	- web.xml，spring，springmvc，mybatis，使用mybatis的逆向工程生成对应的bean以及mapper
5. 测试mapper
---
maven的settings.xml文件配置：



```xml
<!--阿里的仓库镜像-->
<mirrors>
<mirror>
	<id>alimaven</id>
	<name>aliyun maven</name>
    <url>http://maven.aliyun.com/nexus/content/groups/public/</url>
	<mirrorOf>central</mirrorOf>
</mirror>
</mirrors>
```
---
# 查询
1. 访问index.jsp页面
2. index.jsp页面发送出查询员工列表请求
3. EmployeeController来接收请求，查出员工数据
4. 来到list.jsp页面进行展示
5. 使用PageHelper进行分页查询
	- 引入jar包；
	- 在mybatis中配置
	- 在controller对应Controller中引入

- URI： /emps

---
查询-ajax
1. indexl.jsp页面直接发送ajax请求进行员工分页数据的查询
2. 服务器将查出的数据，以json字符串的形式返回给浏览器
3. 浏览器收到js字符串，可以使用js对json进行解析，使用js通过dom增删改来改变页面。
4. 返回json。实现客户端的无关性。

---

新增-逻辑
1. 在index.jsp页面点击“新增”
2. 弹出新增对话框
3. 去数据库查询部门列表，显示在对话框中
4. 用户输入数据完成保存