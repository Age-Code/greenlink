package org.example.greenlink.controller.page.admin;

import org.springframework.stereotype.Controller;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.RequestMapping;

@RequestMapping("/admin/notice")
@Controller
public class NoticeController {
    @RequestMapping("/{page}")
    public String page(@PathVariable String page) { return "admin/notice/" + page; }
    @RequestMapping("/{page}/{id}")
    public String page(@PathVariable String page, @PathVariable String id) { return "admin/notice/" + page; }
}