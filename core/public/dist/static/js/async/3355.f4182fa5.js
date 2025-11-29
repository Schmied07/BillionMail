"use strict";(self.webpackChunkfrontend=self.webpackChunkfrontend||[]).push([["3355"],{90662:function(e,r,t){t.r(r),t.d(r,{default:()=>u});var n=t(29252),o=t(4374),a=t(90290),l=t(12532);let i={class:"h-full p-20px"},c=["src"],s=(0,a.pM)({__name:"index",setup(e){let r=(0,a.KR)(`${window.location.origin}${l.Cu?"/api":""}/rspamd/`);return(e,t)=>{let l=(0,a.g2)("router-link"),s=o.A,u=n.Ay;return(0,a.uX)(),(0,a.CE)("div",i,[(0,a.bF)(u,{class:"mb-16px"},{default:(0,a.k6)(()=>[(0,a.bF)(s,null,{default:(0,a.k6)(()=>[(0,a.bF)(l,{to:"/settings"},{default:(0,a.k6)(()=>[(0,a.eW)((0,a.v_)(e.$t("layout.menu.settings")),1)]),_:1})]),_:1}),(0,a.bF)(s,null,{default:(0,a.k6)(()=>[(0,a.bF)(l,{to:"/settings/service"},{default:(0,a.k6)(()=>[(0,a.eW)((0,a.v_)(e.$t("layout.menu.service")),1)]),_:1})]),_:1}),(0,a.bF)(s,null,{default:(0,a.k6)(()=>[...t[0]||(t[0]=[(0,a.eW)("Rspamd",-1)])]),_:1})]),_:1}),(0,a.Lk)("iframe",{class:"w-full",src:(0,a.R1)(r)},null,8,c)])}}}),u=(0,t(64901).default)(s,[["__scopeId","data-v-8cf9b823"]])},29252:function(e,r,t){t.d(r,{s7:()=>d,Ay:()=>m});var n=t(90290),o=t(49359),a=t(50922),l=t(4019),i=t(29794),c=t(23766),s=t(75454);let u=(0,s.cB)("breadcrumb",`
 white-space: nowrap;
 cursor: default;
 line-height: var(--n-item-line-height);
`,[(0,s.c)("ul",`
 list-style: none;
 padding: 0;
 margin: 0;
 `),(0,s.c)("a",`
 color: inherit;
 text-decoration: inherit;
 `),(0,s.cB)("breadcrumb-item",`
 font-size: var(--n-font-size);
 transition: color .3s var(--n-bezier);
 display: inline-flex;
 align-items: center;
 `,[(0,s.cB)("icon",`
 font-size: 18px;
 vertical-align: -.2em;
 transition: color .3s var(--n-bezier);
 color: var(--n-item-text-color);
 `),(0,s.c)("&:not(:last-child)",[(0,s.cM)("clickable",[(0,s.cE)("link",`
 cursor: pointer;
 `,[(0,s.c)("&:hover",`
 background-color: var(--n-item-color-hover);
 `),(0,s.c)("&:active",`
 background-color: var(--n-item-color-pressed); 
 `)])])]),(0,s.cE)("link",`
 padding: 4px;
 border-radius: var(--n-item-border-radius);
 transition:
 background-color .3s var(--n-bezier),
 color .3s var(--n-bezier);
 color: var(--n-item-text-color);
 position: relative;
 `,[(0,s.c)("&:hover",`
 color: var(--n-item-text-color-hover);
 `,[(0,s.cB)("icon",`
 color: var(--n-item-text-color-hover);
 `)]),(0,s.c)("&:active",`
 color: var(--n-item-text-color-pressed);
 `,[(0,s.cB)("icon",`
 color: var(--n-item-text-color-pressed);
 `)])]),(0,s.cE)("separator",`
 margin: 0 8px;
 color: var(--n-separator-color);
 transition: color .3s var(--n-bezier);
 user-select: none;
 -webkit-user-select: none;
 `),(0,s.c)("&:last-child",[(0,s.cE)("link",`
 font-weight: var(--n-font-weight-active);
 cursor: unset;
 color: var(--n-item-text-color-active);
 `,[(0,s.cB)("icon",`
 color: var(--n-item-text-color-active);
 `)]),(0,s.cE)("separator",`
 display: none;
 `)])])]),d=(0,i.D)("n-breadcrumb"),v=Object.assign(Object.assign({},o.A.props),{separator:{type:String,default:"/"}}),m=(0,n.pM)({name:"Breadcrumb",props:v,setup(e){let{mergedClsPrefixRef:r,inlineThemeDisabled:t}=(0,a.Ay)(e),i=(0,o.A)("Breadcrumb","-breadcrumb",u,c.A,e,r);(0,n.Gt)(d,{separatorRef:(0,n.lW)(e,"separator"),mergedClsPrefixRef:r});let s=(0,n.EW)(()=>{let{common:{cubicBezierEaseInOut:e},self:{separatorColor:r,itemTextColor:t,itemTextColorHover:n,itemTextColorPressed:o,itemTextColorActive:a,fontSize:l,fontWeightActive:c,itemBorderRadius:s,itemColorHover:u,itemColorPressed:d,itemLineHeight:v}}=i.value;return{"--n-font-size":l,"--n-bezier":e,"--n-item-text-color":t,"--n-item-text-color-hover":n,"--n-item-text-color-pressed":o,"--n-item-text-color-active":a,"--n-separator-color":r,"--n-item-color-hover":u,"--n-item-color-pressed":d,"--n-item-border-radius":s,"--n-font-weight-active":c,"--n-item-line-height":v}}),v=t?(0,l.R)("breadcrumb",void 0,s,e):void 0;return{mergedClsPrefix:r,cssVars:t?void 0:s,themeClass:null==v?void 0:v.themeClass,onRender:null==v?void 0:v.onRender}},render(){var e;return null==(e=this.onRender)||e.call(this),(0,n.h)("nav",{class:[`${this.mergedClsPrefix}-breadcrumb`,this.themeClass],style:this.cssVars,"aria-label":"Breadcrumb"},(0,n.h)("ul",null,this.$slots))}})},4374:function(e,r,t){t.d(r,{A:()=>i});var n=t(90290),o=t(49521),a=t(91900),l=t(29252);let i=(0,n.pM)({name:"BreadcrumbItem",props:{separator:String,href:String,clickable:{type:Boolean,default:!0},onClick:Function},slots:Object,setup(e,{slots:r}){let t=(0,n.WQ)(l.s7,null);if(!t)return()=>null;let{separatorRef:i,mergedClsPrefixRef:c}=t,s=function(e=a.B?window:null){let r=()=>{let{hash:r,host:t,hostname:n,href:o,origin:a,pathname:l,port:i,protocol:c,search:s}=(null==e?void 0:e.location)||{};return{hash:r,host:t,hostname:n,href:o,origin:a,pathname:l,port:i,protocol:c,search:s}},t=(0,n.KR)(r()),o=()=>{t.value=r()};return(0,n.sV)(()=>{e&&(e.addEventListener("popstate",o),e.addEventListener("hashchange",o))}),(0,n.hi)(()=>{e&&(e.removeEventListener("popstate",o),e.removeEventListener("hashchange",o))}),t}(),u=(0,n.EW)(()=>e.href?"a":"span"),d=(0,n.EW)(()=>s.value.href===e.href?"location":null);return()=>{let{value:t}=c;return(0,n.h)("li",{class:[`${t}-breadcrumb-item`,e.clickable&&`${t}-breadcrumb-item--clickable`]},(0,n.h)(u.value,{class:`${t}-breadcrumb-item__link`,"aria-current":d.value,href:e.href,onClick:e.onClick},r),(0,n.h)("span",{class:`${t}-breadcrumb-item__separator`,"aria-hidden":"true"},(0,o.Nj)(r.separator,()=>{var r;return[null!=(r=e.separator)?r:i.value]})))}}})}}]);