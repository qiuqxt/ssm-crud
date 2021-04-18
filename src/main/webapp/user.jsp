<%--
  Created by IntelliJ IDEA.
  User: XT
  Date: 2021/4/18
  Time: 13:13
  To change this template use File | Settings | File Templates.
--%>
<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<html>
<head>
    <title>Title</title>

    <script type="text/javascript">

        $.ajax( {
                url:"bmiAjax",
                type:"get",
                data: {name:"lisi",age:20 },
                dataType:"json",

                success:function( data ) {
                    // data 就是responseText, 是jquery处理后的数据。
                }
            }
        )

    </script>
</head>
<body>



</body>
</html>
