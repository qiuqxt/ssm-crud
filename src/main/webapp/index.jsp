<%--
  Created by IntelliJ IDEA.
  User: XT
  Date: 2021/4/15
  Time: 12:07
  To change this template use File | Settings | File Templates.
--%>
<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c"%>
<%@ taglib prefix="C" uri="http://java.sun.com/jsp/jstl/core" %>

<%
    String basePath = request.getScheme()+"://"+request.getServerName()+":"
            +request.getServerPort()+request.getContextPath()+"/";
%>
<html>
<head>
    <!--引入base标签-->
    <base href="<%=basePath%>">
    <title>员工列表</title>

    <!--引入jquery-->
    <script type="text/javascript" src="static/js/jquery-1.12.4.min.js"></script>
    <!--引入样式-->
    <link href="static/bootstrap-3.3.7-dist/css/bootstrap.min.css" rel="stylesheet">
    <script src="static/bootstrap-3.3.7-dist/js/bootstrap.min.js"></script>


    <script type="text/javascript">
        //1.页面加载完成以后，直接去发送一个ajax请求，要到分页数据
        $(function () {
            // 去首页
            to_page(1);
        });

        function to_page(pn) {
            $.ajax({
                url:"<%=basePath%>"+"emps/",
                data:"pn="+pn,
                dataType:"json",
                type:"get",
                success:function (data) {
                    // console.log(data);
                    // alert(data.msg)

                    //1.解析并显示员工数据
                    build_emps_table(data);
                    //2.解析并显示分页信息
                    build_page_info(data);
                    //3.解析显示分页条信息
                    build_page_nav(data);
                }
            })
        }

        function build_emps_table(result) {
            // 清空table表格
            $("#bodyBtn").empty();

            var emps = result.ex.pageInfo.list;
            $.each(emps, function (i,n) {

                var empIdTd = $("<td></td>").append(n.empId);
                var empNameTd = $("<td></td>").append(n.empName);
                var genderTd = $("<td></td>").append(n.gender=='M'?"男":"女");
                var emailTd = $("<td></td>").append(n.email);
                var department = $("<td></td>").append(n.department.deptName);
                /**
                <th>
                <button class="btn btn-primary btn-sm">
                <span class="glyphicon glyphicon-pencil" aria-hidden="true"></span>编辑
                </button>
                <button class="btn btn-danger btn-sm">
                <span class="glyphicon glyphicon-trash" aria-hidden="true"></span>删除
                </button>
                </th>*/
                var editBtn = $("<button></button>").addClass("btn btn-primary btn-sm")
                    .append($("<span></span>").addClass("glyphicon glyphicon-pencil"))
                    .append("编辑");
                var deleteBtn = $("<button></button>").addClass("btn btn-danger btn-sm")
                    .append($("<span></span>").addClass("glyphicon glyphicon-trash"))
                    .append("删除");

                var btnTd = $("<td></td>").append(editBtn).append(" ").append(deleteBtn);

                // append方法执行完成以后还是返回原来的元素
                $("<tr></tr>").append(empIdTd)
                    .append(empNameTd)
                    .append(genderTd)
                    .append(emailTd)
                    .append(department)
                    .append(btnTd)
                    .appendTo($("#bodyBtn"));
            })
        }

        // 解析显示分页信息
        function build_page_info(result){
            // 清空
            $("#page_info_area").empty();

            $("#page_info_area").append("当前"+result.ex.pageInfo.pageNum+"页" +
                ", 总"+result.ex.pageInfo.pages+"页," +
                " 总"+result.ex.pageInfo.total+"记录");
        }

        // 解析显示分页条，点击分页要能去下一页
        function build_page_nav(result) {
            // 清空
            $("#page_nav_area").empty();

            //page_nav_area

            var nav = $("<nav></nav>").attr("aria-label","Page navigation");

            var ul = $("<ul></ul>").addClass("pagination");

            var firstPageLi = $("<li></li>").append($("<a></a>").append("首页").attr("href","#"));
            var prePageLi = $("<li></li>").append($("<a></a>").append("&laquo;"));
            if (result.ex.pageInfo.hasPreviousPage==false){
                firstPageLi.addClass("disabled");
                prePageLi.addClass("disabled");
            }

            // 为首页和前一页绑定单击事件
            firstPageLi.click(function () {
                to_page(1);
            });
            prePageLi.click(function () {
                to_page(result.ex.pageInfo.pageNum-1);

            });

            var nextPageLi = $("<li></li>").append($("<a></a>").append("&raquo;"));
            var lastPageLi = $("<li></li>").append($("<a></a>").append("尾页").attr("href","#"));
            if (result.ex.pageInfo.hasNextPage==false){
                lastPageLi.addClass("disabled");
                nextPageLi.addClass("disabled");
            }
            // 为尾页和后一页绑定单击事件
            lastPageLi.click(function () {
                to_page(result.ex.pageInfo.pages);
            });
            nextPageLi.click(function () {
                to_page(result.ex.pageInfo.pageNum+1);

            });

            // 添加首页和前一页的提示
            ul.append(firstPageLi).append(prePageLi);

            //1,2,3,4,5 遍历给ul中标签添加页面提示
            $.each(result.ex.pageInfo.navigatepageNums, function (i,n) {
                var numLi = $("<li></li>").append($("<a></a>").append(n));

                if (result.ex.pageInfo.pageNum == n){
                    numLi.addClass("active");
                }
                numLi.click(function () {
                    to_page(n)

                })
                ul.append(numLi);
            });

            // 添加下一页和末页的提示
            ul.append().append(nextPageLi).append(lastPageLi);

            // 将ul并入到nav中
            nav.append(ul);

            nav.appendTo($("#page_nav_area"));
        }

    </script>


</head>


<body>

<!--搭建显示界面-->
<div class="container">
    <!--标题-->
    <div class="row">
        <div class="col-md-12"></div>
        <h1>SSM-CRUD</h1>
    </div>
    <!--按钮-->
    <div class="row">
        <div class="col-md-4 col-md-offset-8">
            <button class="btn btn-primary">新增</button>
            <button class="btn btn-danger">删除</button>
        </div>
    </div>
    <!--显示表格数据-->
    <div class="row">
        <div class="col-md-12">
            <table class="table table-hover">
                <thead>
                    <tr>
                        <th>#</th>
                        <th>empName</th>
                        <th>gender</th>
                        <th>email</th>
                        <th>deptName</th>
                        <th>操作</th>
                    </tr>
                </thead>
                <tbody id="bodyBtn">
                    <!--ajax-->
                </tbody>

            </table>

        </div>
    </div>

    <!--显示分页信息-->
    <div class="row">
        <!--分页文字信息-->
        <div class="col-md-6" id="page_info_area">

        </div>
        <!--分页条信息-->
        <div class="col-md-6" id="page_nav_area">


        </div>
    </div>

</div>


</body>
</html>
