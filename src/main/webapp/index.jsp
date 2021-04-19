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

        var totalRecord;
        var currentPage;

        //1.页面加载完成以后，直接去发送一个ajax请求，要到分页数据
        $(function () {
            // 去首页
            to_page(1);

            //点击新增按钮弹出模态框
            $("#emp_add_modal_btn").click(function () {

                //清空模态框表单数据（表单完整重置，表单的数据，表单的样式））

                // $("#emp_add_form")[0].reset();
                reset_form("#emp_add_form");

                getDepts("#dept_select");

                //打开员工新增的模态窗口
                $('#empAddModal').modal({
                    backdrop:"static"
                });

            });

            //校验用户名是否可用
            $("#empName_add_input").change(function () {

                //发送ajax请求，校验用户名是否可用
                var empName = this.value;
                $.ajax( {
                        url:"<%=basePath%>"+"checkUser",
                        type:"post",
                        data: "empName="+empName,

                        success:function( data ) {
                            if (data.code==100){
                                show_validate_msg("#empName_add_input","success","用户名可用");
                                $("#emp_save_btn").attr("ajax-va","success");
                            }else {
                                show_validate_msg("#empName_add_input","error",data.ex.va_msg);
                                $("#emp_save_btn").attr("ajax-va","error");

                            }
                        }
                    }
                )

            });

            //保存按钮
            $("#emp_save_btn").click(function () {
                //模态框中填写的表单数据提交给服务器进行保存

                //1.先对要提交给服务器的数据进行校验
                if(!validate_add_form()){
                    return false;
                }

                //1.判断之前的ajax用户名校验是否成功，失败则return false
                if ($(this).attr("ajax-va")=="error"){
                    //清空模态框表单数据
                    $("#emp_add_form")[0].reset();

                    return false;
                }

                // 表单序列化
                // alert($("#empAddModal form").serialize());

                // 发送ajax请求保存员工
                $.ajax( {
                    url:"<%=basePath%>"+"emp",
                        type:"post",
                        data: $("#empAddModal form").serialize(),   // 表单序列化
                        dataType:"json",

                        success:function( data ) {
                            // alert(data.msg);
                            if (data.code==100){
                                //员工保存成功
                                // 1.关闭模态窗口
                                $('#empAddModal').modal('hide');

                                // 清空模态窗口的数据
                                $("#emp_add_form")[0].reset();

                                // 2.来到最后一页，显示刚才保存的数据
                                // 发送ajax请求显示最后一页数据即可
                                to_page(totalRecord);

                            }else {
                                // 显示失败信息
                                // console.log(data);
                                // 有哪个错误字段的信息就显示哪个字段的
                                if (undefined != data.ex.errorFields.email){
                                    // 显示邮箱错误信息
                                    show_validate_msg("#email_add_input","error",data.ex.errorFields.email);

                                }
                                if (undefined != data.ex.errorFields.empName){
                                    // 显示员工名字的错误信息
                                    show_validate_msg("#empName_add_input","error",data.ex.errorFields.empName);

                                }
                            }
                        }
                    });
            });



            /*
            1.在按钮创建之前就绑定了click，所以绑不上
                1）可以在创建按钮的时候绑定
                2）绑定点击.live()
            jquery新版没有live，使用on进行替代
             */
            // 编辑按钮
            $(document).on("click",".edit_btn", function () {
                // alert(111)

                // 1、查出员工信息，显示
                getEmps($(this).attr("edit-id"));

                // 2、查出部门信息，显示部门列表
                getDepts("#dept_update_select");

                // 3、把员工的id传递给模态框的更新按钮
                $("#emp_update_btn").attr("edit-id",$(this).attr("edit-id"));


                $("#empUpdateModal").modal({
                    backdrop: "static"
                })

            });

            // 点击更新，更新员工信息
            $("#emp_update_btn").click(function () {
                // 验证邮箱合法性
                // 1.校验邮箱信息
                var email = $("#email_update_input").val();
                var regEmail = /^([a-z0-9_\.-]+)@([\da-z\.-]+)\.([a-z\.]{2,6})$/;
                if (!regEmail.test(email)){
                    // alert("邮箱格式不正确");
                    show_validate_msg("#email_update_input", "error", "邮箱格式不正确");
                    return false;
                }else {
                    show_validate_msg("#email_update_input", "success", "");
                }

                // 2.发送ajax请求保存更新的员工数据
                $.ajax( {
                        url:"<%=basePath%>"+"emp/"+$(this).attr("edit-id"),
                        type:"post",
                        data: $("#empUpdateModal form").serialize()+"&_method=put",

                        success:function( data ) {
                            // alert(data.msg);

                            if (data.code==100) {
                                //员工修改成功
                                // 1.关闭模态窗口
                                $('#empUpdateModal').modal('hide');

                                // 回到当前页面
                                to_page(currentPage);
                            }
                        }
                })
            });



            // 单个删除
            $(document).on("click",".delete_btn", function () {
                // 1.弹出是否确认删除对话框
                var empName = $(this).parents("tr").find("td:eq(2)").text();
                var empId = $(this).attr("delete-id");
                if (confirm("确认删除【"+empName+"】")){

                    $.ajax( {
                        url:"<%=basePath%>"+"emp/"+empId,
                        type:"delete",
                        success:function( data ) {
                            alert(data.msg);

                            // 回到当前页面
                            to_page(currentPage);
                        }
                    })
                }

            });


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

            // check_item
            $(document).on("click", ".check_item", function () {
                // 判断当前页选中的元素，是否已经被选满
                if($(".check_item:checked").length==$(".check_item").length){
                    $("#check_all").prop("checked", true);
                }
            })


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

                alert(del_ids);

                if (confirm("确认删除："+empNames+" 吗?")){
                    // 发送ajax请求
                    $.ajax( {
                            url:"<%=basePath%>"+"emp/"+del_ids,
                            type:"delete",
                            success:function( data ) {
                                // data 就是responseText, 是jquery处理后的数据。
                                alert(data.msg);

                                // 回到当前页面
                                to_page(currentPage);
                            }
                    });
                }

            });




        });


        // 获取用户
        function getEmps(id) {

            $.ajax( {
                    url:"<%=basePath%>"+"emp/"+id,
                    type:"get",
                    success:function( data ) {
                        //
                        var empData = data.ex.emp;
                        $("#empName_update_static").text(empData.empName);
                        $("#email_update_input").val(empData.email);
                        $("#empUpdateModal input[name=gender]").val([empData.gender])
                        $("#empUpdateModal select").val([empData.dId])
                    }
                }
            )


        }

        //清空表单数据及样式
        function reset_form(ele) {
            // 重置表单内容
            $(ele)[0].reset();
            //清空表单样式
            $(ele).find("*").removeClass("has-error has-success");
            $(ele).find(".help-block").text("");

        }

        // 校验表单数据
        function validate_add_form() {

            //1.校验用户信息，正则
            var empName = $("#empName_add_input").val();
            var regName = /(^[a-z0-9_-]{6,16}$)|(^[\u2E80-\u9FFF]{2,5})/;
            if(!regName.test(empName)){
                // alert("用户名可以是2-5位中文或者6-16位英文和数字的组合");
                show_validate_msg("#empName_add_input", "error", "用户名可以是2-5位中文或者6-16位英文和数字的组合");
                return false;
            }else {
                show_validate_msg("#empName_add_input", "success", "");
            }

            // 2.校验邮箱信息
            var email = $("#email_add_input").val();
            var regEmail = /^([a-z0-9_\.-]+)@([\da-z\.-]+)\.([a-z\.]{2,6})$/;
            if (!regEmail.test(email)){
                // alert("邮箱格式不正确");
                show_validate_msg("#email_add_input", "error", "邮箱格式不正确");
                return false;
            }else {
                show_validate_msg("#email_add_input", "success", "");
            }

            return true;
        }

        // 显示校验结果的提示信息
        function show_validate_msg(ele,status,msg) {
            //清空这个元素之前的样式
            $(ele).parent().removeClass("has-success has-error");
            $(ele).next("span").text("");

            if ("success"==status){
                $(ele).parent().addClass("has-success");
                $(ele).next("span").text(msg);
            }else if ("error"==status){
                $(ele).parent().addClass("has-error");
                $(ele).next("span").text(msg);
            }

        }


        // 查出所有的部门信息并显示在下拉列表中
        function getDepts(select) {
            $.ajax( {
                url:"<%=basePath%>"+"/depts",
                dataType:"json",
                type:"get",
                success:function( data ) {
                    /*
                    {"code":100,"msg":"处理成功","ex":{"depts":[{"deptId":1,"deptName":"开发部"},{"deptId":2,"deptName":"测试部"}]}}
                     */
                    //console.log(data);

                    // 显示部门信息，在下拉列表中
                    // $("#dept_select")
                    // 先清空
                    $(select).empty();

                    $.each(data.ex.depts, function (i,n) {
                        var option = $("<option value='"+n.deptId+"'></option>").append(n.deptName);
                        option.appendTo($(select))

                    })
                }
                }
            )


        }

        function to_page(pn) {
            $.ajax({
                url:"<%=basePath%>"+"emps",
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

        // 解析并显示员工数据
        function build_emps_table(result) {
            // 清空table表格
            $("#bodyBtn").empty();

            var emps = result.ex.pageInfo.list;
            $.each(emps, function (i,n) {

                var checkBoxId = $("<td></td>").append($("<input type='checkbox' class='check_item'/>"));

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
                var editBtn = $("<button></button>").addClass("btn btn-primary btn-sm edit_btn")
                    .append($("<span></span>").addClass("glyphicon glyphicon-pencil")).append("编辑");
                //为编辑按钮添加一个自定义的属性，来表示当前员工id
                editBtn.attr("edit-id",n.empId);


                var deleteBtn = $("<button></button>").addClass("btn btn-danger btn-sm delete_btn")
                    .append($("<span></span>").addClass("glyphicon glyphicon-trash")).append("删除");
                //为删除按钮添加一个自定义的属性，来表示当前员工id
                deleteBtn.attr("delete-id",n.empId);

                var btnTd = $("<td></td>").append(editBtn).append(" ").append(deleteBtn);

                // append方法执行完成以后还是返回原来的元素
                $("<tr></tr>").append(checkBoxId)
                    .append(empIdTd)
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

            totalRecord = result.ex.pageInfo.total;
            currentPage = result.ex.pageInfo.pageNum;
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
            }else {
                // 为首页和前一页绑定单击事件
                firstPageLi.click(function () {
                    to_page(1);
                });
                prePageLi.click(function () {
                    to_page(result.ex.pageInfo.pageNum-1);

                });
            }

            var nextPageLi = $("<li></li>").append($("<a></a>").append("&raquo;"));
            var lastPageLi = $("<li></li>").append($("<a></a>").append("尾页").attr("href","#"));
            if (result.ex.pageInfo.hasNextPage==false){
                lastPageLi.addClass("disabled");
                nextPageLi.addClass("disabled");
            }else {
                // 为尾页和后一页绑定单击事件
                lastPageLi.click(function () {
                    to_page(result.ex.pageInfo.pages);
                });
                nextPageLi.click(function () {
                    to_page(result.ex.pageInfo.pageNum+1);

                });
            }

            // 添加首页和前一页的提示
            ul.append(firstPageLi).append(prePageLi);

            //1,2,3,4,5 遍历给ul中标签添加页面提示
            $.each(result.ex.pageInfo.navigatepageNums, function (i,n) {
                var numLi = $("<li></li>").append($("<a style='cursor: pointer'></a>").append(n));

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

    <!--员工修改模态窗-->
    <!-- Modal -->
    <div class="modal fade" id="empUpdateModal" tabindex="-1" role="dialog" aria-labelledby="myModalLabel">
    <div class="modal-dialog" role="document">
        <div class="modal-content">
            <div class="modal-header">
                <button type="button" class="close" data-dismiss="modal" aria-label="Close"><span aria-hidden="true">&times;</span></button>
                <h4 class="modal-title">员工修改</h4>
            </div>
            <div class="modal-body">

                <form class="form-horizontal">
                    <div class="form-group">
                        <label class="col-sm-2 control-label">empName</label>
                        <div class="col-sm-10">
                            <p class="form-control-static" id="empName_update_static"></p>
                            <span class="help-block"></span>
                        </div>
                    </div>
                    <div class="form-group">
                        <label class="col-sm-2 control-label">email</label>
                        <div class="col-sm-10">
                            <input type="email" class="form-control" name="email" id="email_update_input" placeholder="email@163.com">
                            <span class="help-block"></span>
                        </div>
                    </div>
                    <div class="form-group">
                        <label class="col-sm-2 control-label">gender</label>
                        <div class="col-sm-10">
                            <label class="radio-inline">
                                <input type="radio" name="gender" id="gender1_update_input" value="M" checked> 男
                            </label>
                            <label class="radio-inline">
                                <input type="radio" name="gender" id="gender2_update_input" value="F"> 女
                            </label>
                        </div>
                    </div>
                    <div class="form-group">
                        <label class="col-sm-2 control-label">deptName</label>
                        <div class="col-sm-5">
                            <!--部门提交部门id即可-->
                            <select class="form-control" name="dId" id="dept_update_select"></select>
                        </div>
                    </div>

                </form>

            </div>
            <div class="modal-footer">
                <button type="button" class="btn btn-default" data-dismiss="modal">关闭</button>
                <button type="button" class="btn btn-primary" id="emp_update_btn">修改</button>
            </div>
        </div>
    </div>
</div>


    <!--员工添加的模态窗-->
    <!-- Modal -->
    <div class="modal fade" id="empAddModal" tabindex="-1" role="dialog" aria-labelledby="myModalLabel">
        <div class="modal-dialog" role="document">
            <div class="modal-content">
                <div class="modal-header">
                    <button type="button" class="close" data-dismiss="modal" aria-label="Close"><span aria-hidden="true">&times;</span></button>
                    <h4 class="modal-title" id="myModalLabel">员工添加</h4>
                </div>
                <div class="modal-body">

                    <form class="form-horizontal" id="emp_add_form">
                        <div class="form-group">
                            <label class="col-sm-2 control-label">empName</label>
                            <div class="col-sm-10">
                                <input type="email" class="form-control" name="empName" id="empName_add_input" placeholder="empName">
                                <span class="help-block"></span>
                            </div>
                        </div>
                        <div class="form-group">
                            <label class="col-sm-2 control-label">email</label>
                            <div class="col-sm-10">
                                <input type="email" class="form-control" name="email" id="email_add_input" placeholder="email@163.com">
                                <span class="help-block"></span>
                            </div>
                        </div>
                        <div class="form-group">
                            <label class="col-sm-2 control-label">gender</label>
                            <div class="col-sm-10">
                                <label class="radio-inline">
                                    <input type="radio" name="gender" id="gender1_add_input" value="M" checked> 男
                                </label>
                                <label class="radio-inline">
                                    <input type="radio" name="gender" id="gender2_add_input" value="F"> 女
                                </label>
                            </div>
                        </div>
                        <div class="form-group">
                            <label class="col-sm-2 control-label">deptName</label>
                            <div class="col-sm-5">
                                <!--部门提交部门id即可-->
                                <select class="form-control" name="dId" id="dept_select"></select>
                            </div>
                        </div>

                    </form>

                </div>
                <div class="modal-footer">
                    <button type="button" class="btn btn-default" data-dismiss="modal">关闭</button>
                    <button type="button" class="btn btn-primary" id="emp_save_btn">保存</button>
                </div>
            </div>
        </div>
    </div>


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
                <button type="button" class="btn btn-primary" id="emp_add_modal_btn">新增</button>
                <button class="btn btn-danger" id="emp_delete_all_btn">删除</button>
            </div>
        </div>
        <!--显示表格数据-->
        <div class="row">
            <div class="col-md-12">
                <table class="table table-hover">
                    <thead>
                        <tr>
                            <th>
                                <input type="checkbox" id="check_all"/>
                            </th>
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
