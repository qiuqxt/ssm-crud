package cn.albert.crud.controller;

import cn.albert.crud.bean.Department;
import cn.albert.crud.bean.Msg;
import cn.albert.crud.service.DepartmentService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Controller;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.ResponseBody;

import java.util.List;

/**
 * 处理部门有关的请求
 */
@Controller
public class DepartmentController {

    @Autowired
    private DepartmentService departmentService;

    /**
     * 返回所有的部门信息
     */
    @RequestMapping("/depts")
    @ResponseBody
    public Msg getDepts(){

        // 查出的所有部门信息
        List<Department> Ldept = departmentService.getDepts();

        return Msg.success().add("depts",Ldept);
    }
}
