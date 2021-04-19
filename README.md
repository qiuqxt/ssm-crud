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
# 查询-ajax
1. indexl.jsp页面直接发送ajax请求进行员工分页数据的查询
2. 服务器将查出的数据，以json字符串的形式返回给浏览器
3. 浏览器收到js字符串，可以使用js对json进行解析，使用js通过dom增删改来改变页面。
4. 返回json。实现客户端的无关性。

---


# 新增-逻辑
1. 在index.jsp页面点击“新增”
2. 弹出新增对话框
3. 去数据库查询部门列表，显示在对话框中
4. 用户输入数据，校验数据
	- jquery前端校验（`正则表达式`），ajax用户名重复校验，重要数据（后端校验（**JSR303**），唯一约束）；
	- 后端校验：①引入JSR包，在对应的bean中的java文件的相应字段上加注解（`@Pattern(regexp="正则表达式", message="自定义信息")`）；②在对应controller中的方法形参中加注解（`@Valid 形参， BindingResult result`）

5. 发送ajax请求时，使用表单序列化传递参数信息（`data: $("#empAddModal form").serialize(),   // 表单序列化`）
6. 完成保存, 

- URI：
- /emp/{id}     GET 查询员工
- /emp     POST保存
- /emp/{id}     PUT 修改员工
- /emp{id} DELETE 删除员工
---

# 修改-逻辑
1. 点击编辑
2. 弹出用户修改的模态框（显示用户信息）
3. 点击更新，完成用户的修改

---
# 删除-逻辑
1. 单个删除
	- URI:/emp{id}
	- 弹出删除确认框【`if(confirm("确认删除吗？")){。。。}`】

2. 全选/全不选

```javascript
// 完成全选/全不选功能
            $("#check_all").click(function () {
                /**
                 * attr获取checked是undefined，推荐自定义的属性用attr获取值;
                 * 像这些原生的dom属性，推荐不用attr获取值，使用prop获取值;
                 * prop修改和读取dom原生属性的值
                 */
                // alert($(this).prop("checked"));
                $(".check_item").prop("checked", $(this).prop("checked"));

            })
```

```javascript
// check_item
            $(document).on("click", ".check_item", function () {
                // 判断当前页选中的元素，是否已经被选满
                if($(".check_item:checked").length==$(".check_item").length){

                    $("#check_all").prop("checked", true);

                }
            })
```

```javascript
// 批量删除
            $("#emp_delete_all_btn").click(function () {

                var empNames = "";
                var del_ids = "";

                $.each($(".check_item:checked"), function () {
                    // 员工姓名字符串
                    empNames += $(this).parents("tr").find("td:eq(2)").text() + ",";
                    // 员工id字符串
                    del_ids += $(this).parents("tr").find("td:eq(1)").text() + "-";

                });

                // 去除多余的“，”号
                empNames = empNames.substring(0, empNames.length-1);
                del_ids = del_ids.substring(0, del_ids.length-1);

                if (confirm("确认删除："+empNames+" 吗?")){
                    // 发送ajax请求
                    $.ajax( {
                            url:"<%=basePath%>"+"emp/"+del_ids,
                            type:"delete",
                            success:function( data ) {
                                // data 就是responseText, 是jquery处理后的数据。
                            }
                    });
                }
            });
```

---
# 总结
