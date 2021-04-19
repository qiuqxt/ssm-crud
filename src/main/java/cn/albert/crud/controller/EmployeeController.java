package cn.albert.crud.controller;

import cn.albert.crud.bean.Employee;
import cn.albert.crud.bean.Msg;
import cn.albert.crud.service.EmployeeService;
import com.github.pagehelper.PageHelper;
import com.github.pagehelper.PageInfo;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.validation.BindingResult;
import org.springframework.validation.FieldError;
import org.springframework.web.bind.annotation.*;

import javax.validation.Valid;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

/**
 * 处理员工CRUD请求
 */
@Controller
public class EmployeeController {

    @Autowired
    EmployeeService employeeService;

    @RequestMapping(value = "/emp/{empId}", method = RequestMethod.DELETE)
    @ResponseBody
    public Msg deleteEmp(@PathVariable("empId") Integer id){

        employeeService.deleteEmp(id);

        return Msg.success();
    }

    /**
     * 如果直接发送ajax=PUT形式的请求，
     * 封装的数据
     * Employee
     * [empId=1028, empName=null, gender=null, email=null, dId=null]
     *
     * 问题：
     *  请求体中有数据，但是Employee对象封装不上
     *
     * 原因：
     *  Tomcat：
     *      1、请求体中的数据，封装一个map。
     *      2、request.getParameter("empName")就会从这个map中取值。
     *      3、SpringMVC封装POJO对象的时候
     *          会把POJO中每个属性的值，request.getParameter("email");
     *
     * Ajax发送PUT请求引发的血案：
     *      PUT请求，请求体中的数据，request.getParameter("empName")拿不到
     *      Tomcat一看是PUT请求，便不会封装请求体重的数据为map，只有POST形式的请求才封装请求体为map
     *
     *
     * 解决方案：
     * 我们要 能支持直接发送PUT之类的请求，还要封装请求体中的数据
     *  1、配置上HttpPutFormContentFilter
     *  2、作用：将请求体中的数据解析包装成一个map
     *  3、request被重新包装，request.getParameter()被重写，就会从自己封装的map中获取数据
     *
     *
     * 员工更新方法
     * @param employee
     * @return
     */
    @RequestMapping(value = "/emp/{empId}", method = RequestMethod.PUT)
    @ResponseBody
    public Msg updateEmp(Employee employee){

        employeeService.updateEmp(employee);

        return Msg.success();
    }
    /**
     * 根据id查询员工
     */
    @RequestMapping(value = "/emp/{id}",method = RequestMethod.GET)
    @ResponseBody
    public Msg getEmp(@PathVariable("id") Integer id){

        Employee employee = employeeService.getEmp(id);

        return Msg.success().add("emp", employee);
    }

    /**
     * 检查用户名是否可用
     * @param empName
     * @return
     */
    @RequestMapping("/checkUser")
    @ResponseBody
    public Msg checkUser(@RequestParam("empName") String empName){
        // 先判断用户名是否是合法的表达式
        String regx = "(^[a-z0-9_-]{6,16}$)|(^[\\u2E80-\\u9FFF]{2,5})";
        if (!empName.matches(regx)){
            return Msg.fail().add("va_msg", "用户名必须是6-16位数字和字母的组合或者2-5位中文");
        }

        // 数据库用户名重复校验
        boolean flag = employeeService.checkUser(empName);
        if (flag){
            return Msg.success();
        }else {
            return Msg.fail().add("va_msg","用户名不可用");
        }
    }


    /**
     * 员工保存
     * 1、支持JSR303校验
     * 2、导入Hibernate-Validator
     * @return
     */
    @RequestMapping(value = "/emp", method = RequestMethod.POST)
    @ResponseBody
    public Msg saveEmp(@Valid Employee employee, BindingResult result){
        if (result.hasErrors()){
            //校验失败，不应该保存员工，应该返回失败，在模态框中显示校验失败的错误信息
            Map<String, Object> map = new HashMap<>();
            List<FieldError> fieldErrors = result.getFieldErrors();
            for (FieldError fieldError : fieldErrors) {
                System.out.println("错误的字段名："+fieldError.getField());
                System.out.println("错误信息："+fieldError.getDefaultMessage());
                map.put(fieldError.getField(),fieldError.getDefaultMessage());
            }
            return Msg.fail().add("errorFields", map);

        }else {
            employeeService.saveEmp(employee);
            return Msg.success();
        }
    }

    /**
     * 导入Jackson包，使得ResponseBody生效
     * @param pn
     * @return
     */
    @RequestMapping("/emps")
    @ResponseBody
    public Msg getEmpsWithJson(@RequestParam(value = "pn", defaultValue = "1")Integer pn){
        // 引入PageHelper分页插件
        // 在查询之前只需要调用，传入页码，以及每页的大小
        PageHelper.startPage(pn,5);
        // startPage后面紧跟的这个查询就是一个分页查询
        List<Employee> emps = employeeService.getAll();
        // 用PageInfo对结果进行包装，只需要将pageInfo交给页面就行了。
        // 封装了详细的分页信息，包括有我们查询出来的数据，传入连续显示的页数5
        PageInfo page = new PageInfo(emps,5);
        return Msg.success().add("pageInfo",page);
    }

    /**
     * 查询员工数据（分页查询）
     * @return
     */
    //@RequestMapping("/emps")
    public String getEmps(@RequestParam(value = "pn", defaultValue = "1")Integer pn,
                          Model model){
        //这不是一个分页查询
        // 引入PageHelper分页插件
        // 在查询之前只需要调用，传入页码，以及每页的大小
        PageHelper.startPage(pn,5);
        // startPage后面紧跟的这个查询就是一个分页查询
        List<Employee> emps = employeeService.getAll();
        // 用PageInfo对结果进行包装，只需要将pageInfo交给页面就行了。
        // 封装了详细的分页信息，包括有我们查询出来的数据，传入连续显示的页数5
        PageInfo page = new PageInfo(emps,5);
        model.addAttribute("pageInfo",page);
        return "list";
    }
}
