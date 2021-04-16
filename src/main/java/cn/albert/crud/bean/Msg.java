package cn.albert.crud.bean;

import com.github.pagehelper.PageInfo;

import java.util.HashMap;
import java.util.Map;

/**
 * 通用的返回类
 */
public class Msg {
    // 状态码 100-成功 200-失败
    private int code;

    // 提示信息
    private String msg;

    // 用户要返回给浏览器的数据
    private Map<String, Object> ex = new HashMap<>();

    public static Msg success(){
        Msg result = new Msg();
        result.setCode(100);
        result.setMsg("处理成功");
        return result;
    }

    public static Msg fail(){
        Msg result = new Msg();
        result.setCode(200);
        result.setMsg("处理失败");
        return result;
    }

    public int getCode() {
        return code;
    }

    public void setCode(int code) {
        this.code = code;
    }

    public String getMsg() {
        return msg;
    }

    public void setMsg(String msg) {
        this.msg = msg;
    }

    public Map<String, Object> getEx() {
        return ex;
    }

    public void setEx(Map<String, Object> ex) {
        this.ex = ex;
    }

    public Msg add(String pageInfo, PageInfo page) {
        this.getEx().put(pageInfo,page);
        return this;
    }
}
