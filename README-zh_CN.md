<div align="center">
  <a name="readme-top"></a>
  <h1><a href="https://www.tetrisnewsemailing.com/" target="_blank">TetrisNewsEmailing 📧</a></h1>


## 一个开源的邮件服务器，为智能营销提供电子邮件解决方案

[![][license-shield]][license-link] [![][docs-shield]][docs-link] [![][github-release-shield]][github-release-link] [![][github-stars-shield]][github-stars-link]

[English](README.md) | 简体中文 | [日本語](README-ja.md) | [Türkçe](README-ja.md)
</div>
<br/>

<div align="center">
<a href="https://trendshift.io/repositories/13842" target="_blank"><img src="https://trendshift.io/api/badge/repositories/13842" alt="aaPanel%2FTetrisNewsEmailing | Trendshift" style="width: 250px; height: 55px;" width="250" height="55"/></a>
</div>

## 在线演示
TetrisNewsEmailing 演示: [https://demo.tetrisnewsemailing.com/tetrisnewsemailing](https://demo.tetrisnewsemailing.com/tetrisnewsemailing)

用户名: `tetrisnewsemailing` 

密码: `tetrisnewsemailing` 

## 什么是 TetrisNewsEmailing？

TetrisNewsEmailing 是一个**未来的开源邮件服务器和电子邮件营销平台**，旨在帮助企业和个人轻松管理他们的电子邮件营销活动。无论您是发送新闻通讯、促销邮件还是交易消息，这个工具都将为您的电子邮件营销工作提供**完全控制**。通过**高级分析**和**客户管理**等功能，您将能够像专业人士一样创建、发送和跟踪电子邮件。

![TetrisNewsEmailing Banner](https://www.tetrisnewsemailing.com/home.png?v1)

## 如何使用？
**安装脚本：** (✅该脚本会自动安装所有必需的运行环境，包括Docker)
```shell
cd /opt && git clone https://github.com/aaPanel/TetrisNewsEmailing && cd TetrisNewsEmailing && bash install.sh
```


**使用Docker安装：** (请手动安装Docker和docker-compose-plugin，并修改.env文件)
```shell
cd /opt && git clone https://github.com/aaPanel/TetrisNewsEmailing && cd TetrisNewsEmailing && cp env_init .env && docker compose up -d || docker-compose up -d
```

<div align="center">
  <a href="https://www.bilibili.com/video/BV1JiTNzUE5m/" target="_blank">
    <img src="https://i1.hdslb.com/bfs/archive/9065dbdf7645fa5cadb8a34e1ae3e287481fb862.jpg" alt="" width="80%">
    <br />
    <b>在BiliBili上观看</b>
  </a>
</div>


## 管理脚本
- 管理帮助

  `bm help`

- 查看默认登录信息

  `bm default`

- 显示域名DNS记录

  `bm show-record`

- 更新TetrisNewsEmailing

  `bm update`



## 网页邮箱

TetrisNewsEmailing已集成**RoundCube**，您可以通过`/roundcube/`访问网页邮箱。

## 为什么选择TetrisNewsEmailing？

### 大多数电子邮件营销平台要么**昂贵**，要么**闭源**，或者**缺乏基本功能**。TetrisNewsEmailing的目标是与众不同：

✅ **完全开源** – 没有隐藏成本，没有供应商锁定。  
📊 **高级分析** – 跟踪电子邮件投递、打开率、点击率等。  
📧 **无限发送** – 对您可以发送的电子邮件数量没有限制。  
🎨 **可定制模板** – 可重复使用的专业营销模板。
🔒 **隐私优先** – 您的数据保留在您这里，没有第三方跟踪。  
🚀 **自托管** – 在您自己的服务器上运行，完全控制。  

## 您如何提供帮助 🌟

TetrisNewsEmailing是一个**社区驱动的项目**，我们需要您的支持才能开始！以下是您可以提供帮助的方式：

1. **为此仓库加星标**：通过为此仓库加星表示您的兴趣。  
2. **传播消息**：与您的网络分享TetrisNewsEmailing—开发者、营销人员和开源爱好者。  
3. **分享反馈**：通过提出问题或加入讨论，让我们知道您希望在TetrisNewsEmailing中看到哪些功能。  
4. **贡献**：一旦开发开始，我们将欢迎社区的贡献。敬请关注更新！

---

📧 **TetrisNewsEmailing – 开源电子邮件营销的未来。**

## 问题

如果您遇到任何问题或有功能请求，请[提交issue](https://github.com/aaPanel/TetrisNewsEmailing/issues)。请确保包括：

- 问题或请求的清晰描述。
- 重现问题的步骤（如适用）。
- 截图或错误日志（如适用）。

## 许可证

TetrisNewsEmailing根据**AGPLv3许可证**授权。这意味着您可以：

✅ 免费使用该软件。  
✅ 修改和分发代码。  
✅ 私下使用，没有限制。

有关更多详细信息，请参阅[LICENSE](LICENSE)文件。


<!-- TetrisNewsEmailing official link -->
[docs-link]: https://www.tetrisnewsemailing.com/

<!-- TetrisNewsEmailing Other link-->
[license-link]: https://www.gnu.org/licenses/gpl-3.0.html
[github-release-link]: https://github.com/aaPanel/TetrisNewsEmailing/releases/latest
[github-stars-link]: https://github.com/aaPanel/TetrisNewsEmailing
[github-issues-link]: https://github.com/aaPanel/TetrisNewsEmailing/issues

<!-- Shield link-->
[docs-shield]: https://img.shields.io/badge/documentation-148F76
[github-release-shield]: https://img.shields.io/github/v/release/aaPanel/TetrisNewsEmailing
[github-stars-shield]: https://img.shields.io/github/stars/aaPanel/TetrisNewsEmailing?color=%231890FF&style=flat-square   
[license-shield]: https://img.shields.io/github/license/aaPanel/TetrisNewsEmailing
