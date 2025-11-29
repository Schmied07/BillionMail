"use strict";(self.webpackChunkfrontend=self.webpackChunkfrontend||[]).push([["9802"],{11051:function(e,o,n){n.d(o,{A:()=>l});var t=n(90290),r=n(61853),i=n(63979);function l(e={},o){let n=(0,t.Kh)({ctrl:!1,command:!1,win:!1,shift:!1,tab:!1}),{keydown:d,keyup:a}=e,s=e=>{switch(e.key){case"Control":n.ctrl=!0;break;case"Meta":n.command=!0,n.win=!0;break;case"Shift":n.shift=!0;break;case"Tab":n.tab=!0}void 0!==d&&Object.keys(d).forEach(o=>{if(o!==e.key)return;let n=d[o];if("function"==typeof n)n(e);else{let{stop:o=!1,prevent:t=!1}=n;o&&e.stopPropagation(),t&&e.preventDefault(),n.handler(e)}})},u=e=>{switch(e.key){case"Control":n.ctrl=!1;break;case"Meta":n.command=!1,n.win=!1;break;case"Shift":n.shift=!1;break;case"Tab":n.tab=!1}void 0!==a&&Object.keys(a).forEach(o=>{if(o!==e.key)return;let n=a[o];if("function"==typeof n)n(e);else{let{stop:o=!1,prevent:t=!1}=n;o&&e.stopPropagation(),t&&e.preventDefault(),n.handler(e)}})},p=()=>{(void 0===o||o.value)&&((0,r.on)("keydown",document,s),(0,r.on)("keyup",document,u)),void 0!==o&&(0,t.wB)(o,e=>{e?((0,r.on)("keydown",document,s),(0,r.on)("keyup",document,u)):((0,r.A)("keydown",document,s),(0,r.A)("keyup",document,u))})};return(0,i.a)()?((0,t.KC)(p),(0,t.xo)(()=>{(void 0===o||o.value)&&((0,r.A)("keydown",document,s),(0,r.A)("keyup",document,u))})):p(),(0,t.tB)(n)}},71877:function(e,o,n){n.d(o,{A:()=>r});var t=n(90290);let r=(0,t.pM)({name:"ChevronRight",render:()=>(0,t.h)("svg",{viewBox:"0 0 16 16",fill:"none",xmlns:"http://www.w3.org/2000/svg"},(0,t.h)("path",{d:"M5.64645 3.14645C5.45118 3.34171 5.45118 3.65829 5.64645 3.85355L9.79289 8L5.64645 12.1464C5.45118 12.3417 5.45118 12.6583 5.64645 12.8536C5.84171 13.0488 6.15829 13.0488 6.35355 12.8536L10.8536 8.35355C11.0488 8.15829 11.0488 7.84171 10.8536 7.64645L6.35355 3.14645C6.15829 2.95118 5.84171 2.95118 5.64645 3.14645Z",fill:"currentColor"}))})},87180:function(e,o,n){n.d(o,{V:()=>t});function t(e){return o=>{o?e.value=o.$el:e.value=null}}},80785:function(e,o,n){n.d(o,{A:()=>q});var t=n(91929),r=n(5562),i=n(29440),l=n(11051),d=n(90290),a=n(49359),s=n(50922),u=n(4019),p=n(16680),c=n(75454),h=n(87180),v=n(33199),f=n(18672),w=n(9543),b=n(29794);let m=(0,b.D)("n-dropdown-menu"),y=(0,b.D)("n-dropdown"),x=(0,b.D)("n-dropdown-option");var g=n(34828),k=n(89422),S=n(67794),A=n(71270),N=n(25792);let C=(0,d.pM)({name:"DropdownDivider",props:{clsPrefix:{type:String,required:!0}},render(){return(0,d.h)("div",{class:`${this.clsPrefix}-dropdown-divider`})}});var W=n(11601),P=n(4744);let E=(0,d.pM)({name:"DropdownGroupHeader",props:{clsPrefix:{type:String,required:!0},tmNode:{type:Object,required:!0}},setup(){let{showIconRef:e,hasSubmenuRef:o}=(0,d.WQ)(m),{renderLabelRef:n,labelFieldRef:t,nodePropsRef:r,renderOptionRef:i}=(0,d.WQ)(y);return{labelField:t,showIcon:e,hasSubmenu:o,renderLabel:n,nodeProps:r,renderOption:i}},render(){var e;let{clsPrefix:o,hasSubmenu:n,showIcon:t,nodeProps:r,renderLabel:i,renderOption:l}=this,{rawNode:a}=this.tmNode,s=(0,d.h)("div",Object.assign({class:`${o}-dropdown-option`},null==r?void 0:r(a)),(0,d.h)("div",{class:`${o}-dropdown-option-body ${o}-dropdown-option-body--group`},(0,d.h)("div",{"data-dropdown-option":!0,class:[`${o}-dropdown-option-body__prefix`,t&&`${o}-dropdown-option-body__prefix--show-icon`]},(0,P.X)(a.icon)),(0,d.h)("div",{class:`${o}-dropdown-option-body__label`,"data-dropdown-option":!0},i?i(a):(0,P.X)(null!=(e=a.title)?e:a[this.labelField])),(0,d.h)("div",{class:[`${o}-dropdown-option-body__suffix`,n&&`${o}-dropdown-option-body__suffix--has-submenu`],"data-dropdown-option":!0})));return l?l({node:s,option:a}):s}});var $=n(73587),M=n(14642),R=n(28895),B=n(38748),O=n(71877),z=n(82078);function F(e,o){return"submenu"===e.type||void 0===e.type&&void 0!==e[o]}function I(e){return"divider"===e.type}let _=(0,d.pM)({name:"DropdownOption",props:{clsPrefix:{type:String,required:!0},tmNode:{type:Object,required:!0},parentKey:{type:[String,Number],default:null},placement:{type:String,default:"right-start"},props:Object,scrollable:Boolean},setup(e){var o,n,t;let r,l,a=(0,d.WQ)(y),{hoverKeyRef:s,keyboardKeyRef:u,lastToggledSubmenuKeyRef:p,pendingKeyPathRef:c,activeKeyPathRef:h,animatedRef:v,mergedShowRef:f,renderLabelRef:w,renderIconRef:b,labelFieldRef:g,childrenFieldRef:k,renderOptionRef:S,nodePropsRef:N,menuPropsRef:C}=a,W=(0,d.WQ)(x,null),P=(0,d.WQ)(m),E=(0,d.WQ)(A.U),M=(0,d.EW)(()=>e.tmNode.rawNode),R=(0,d.EW)(()=>{let{value:o}=k;return F(e.tmNode.rawNode,o)}),B=(0,d.EW)(()=>{let{disabled:o}=e.tmNode;return o}),O=(o=(0,d.EW)(()=>{if(!R.value)return!1;let{key:o,disabled:n}=e.tmNode;if(n)return!1;let{value:t}=s,{value:r}=u,{value:i}=p,{value:l}=c;return null!==t?l.includes(o):null!==r?l.includes(o)&&l[l.length-1]!==o:null!==i&&l.includes(o)}),n=0,t=(0,d.EW)(()=>null===u.value&&!v.value),r=(0,d.KR)(o.value),l=null,(0,d.wB)(o,e=>{null!==l&&window.clearTimeout(l),!0===e?t&&!t.value?r.value=!0:l=window.setTimeout(()=>{r.value=!0},300):r.value=!1}),r),z=(0,d.EW)(()=>!!(null==W?void 0:W.enteringSubmenuRef.value)),I=(0,d.KR)(!1);function _(){let{parentKey:o,tmNode:n}=e;n.disabled||f.value&&(p.value=o,u.value=null,s.value=n.key)}return(0,d.Gt)(x,{enteringSubmenuRef:I}),{labelField:g,renderLabel:w,renderIcon:b,siblingHasIcon:P.showIconRef,siblingHasSubmenu:P.hasSubmenuRef,menuProps:C,popoverBody:E,animated:v,mergedShowSubmenu:(0,d.EW)(()=>O.value&&!z.value),rawNode:M,hasSubmenu:R,pending:(0,i.A)(()=>{let{value:o}=c,{key:n}=e.tmNode;return o.includes(n)}),childActive:(0,i.A)(()=>{let{value:o}=h,{key:n}=e.tmNode,t=o.findIndex(e=>n===e);return -1!==t&&t<o.length-1}),active:(0,i.A)(()=>{let{value:o}=h,{key:n}=e.tmNode,t=o.findIndex(e=>n===e);return -1!==t&&t===o.length-1}),mergedDisabled:B,renderOption:S,nodeProps:N,handleClick:function(){let{value:o}=R,{tmNode:n}=e;f.value&&(o||n.disabled||(a.doSelect(n.key,n.rawNode),a.doUpdateShow(!1)))},handleMouseMove:function(){let{tmNode:o}=e;o.disabled||!f.value||s.value!==o.key&&_()},handleMouseEnter:_,handleMouseLeave:function(o){if(e.tmNode.disabled||!f.value)return;let{relatedTarget:n}=o;!n||(0,$.d)({target:n},"dropdownOption")||(0,$.d)({target:n},"scrollbarRail")||(s.value=null)},handleSubmenuBeforeEnter:function(){I.value=!0},handleSubmenuAfterEnter:function(){I.value=!1}}},render(){var e,o;let{animated:n,rawNode:t,mergedShowSubmenu:r,clsPrefix:i,siblingHasIcon:l,siblingHasSubmenu:a,renderLabel:s,renderIcon:u,renderOption:p,nodeProps:c,props:h,scrollable:v}=this,f=null;if(r){let o=null==(e=this.menuProps)?void 0:e.call(this,t,t.children);f=(0,d.h)(j,Object.assign({},o,{clsPrefix:i,scrollable:this.scrollable,tmNodes:this.tmNode.children,parentKey:this.tmNode.key}))}let w={class:[`${i}-dropdown-option-body`,this.pending&&`${i}-dropdown-option-body--pending`,this.active&&`${i}-dropdown-option-body--active`,this.childActive&&`${i}-dropdown-option-body--child-active`,this.mergedDisabled&&`${i}-dropdown-option-body--disabled`],onMousemove:this.handleMouseMove,onMouseenter:this.handleMouseEnter,onMouseleave:this.handleMouseLeave,onClick:this.handleClick},b=null==c?void 0:c(t),m=(0,d.h)("div",Object.assign({class:[`${i}-dropdown-option`,null==b?void 0:b.class],"data-dropdown-option":!0},b),(0,d.h)("div",(0,d.v6)(w,h),[(0,d.h)("div",{class:[`${i}-dropdown-option-body__prefix`,l&&`${i}-dropdown-option-body__prefix--show-icon`]},[u?u(t):(0,P.X)(t.icon)]),(0,d.h)("div",{"data-dropdown-option":!0,class:`${i}-dropdown-option-body__label`},s?s(t):(0,P.X)(null!=(o=t[this.labelField])?o:t.title)),(0,d.h)("div",{"data-dropdown-option":!0,class:[`${i}-dropdown-option-body__suffix`,a&&`${i}-dropdown-option-body__suffix--has-submenu`]},this.hasSubmenu?(0,d.h)(z._,null,{default:()=>(0,d.h)(O.A,null)}):null)]),this.hasSubmenu?(0,d.h)(M.A,null,{default:()=>[(0,d.h)(R.A,null,{default:()=>(0,d.h)("div",{class:`${i}-dropdown-offset-container`},(0,d.h)(B.A,{show:this.mergedShowSubmenu,placement:this.placement,to:v&&this.popoverBody||void 0,teleportDisabled:!v},{default:()=>(0,d.h)("div",{class:`${i}-dropdown-menu-wrapper`},n?(0,d.h)(d.eB,{onBeforeEnter:this.handleSubmenuBeforeEnter,onAfterEnter:this.handleSubmenuAfterEnter,name:"fade-in-scale-up-transition",appear:!0},{default:()=>f}):f)}))})]}):null);return p?p({node:m,option:t}):m}}),D=(0,d.pM)({name:"NDropdownGroup",props:{clsPrefix:{type:String,required:!0},tmNode:{type:Object,required:!0},parentKey:{type:[String,Number],default:null}},render(){let{tmNode:e,parentKey:o,clsPrefix:n}=this,{children:t}=e;return(0,d.h)(d.FK,null,(0,d.h)(E,{clsPrefix:n,tmNode:e,key:e.key}),null==t?void 0:t.map(e=>{let{rawNode:t}=e;return!1===t.show?null:I(t)?(0,d.h)(C,{clsPrefix:n,key:e.key}):e.isGroup?((0,W.R8)("dropdown","`group` node is not allowed to be put in `group` node."),null):(0,d.h)(_,{clsPrefix:n,tmNode:e,parentKey:o,key:e.key})}))}}),K=(0,d.pM)({name:"DropdownRenderOption",props:{tmNode:{type:Object,required:!0}},render(){let{rawNode:{render:e,props:o}}=this.tmNode;return(0,d.h)("div",o,[null==e?void 0:e()])}}),j=(0,d.pM)({name:"DropdownMenu",props:{scrollable:Boolean,showArrow:Boolean,arrowStyle:[String,Object],clsPrefix:{type:String,required:!0},tmNodes:{type:Array,default:()=>[]},parentKey:{type:[String,Number],default:null}},setup(e){let{renderIconRef:o,childrenFieldRef:n}=(0,d.WQ)(y);(0,d.Gt)(m,{showIconRef:(0,d.EW)(()=>{let n=o.value;return e.tmNodes.some(e=>{var o;if(e.isGroup)return null==(o=e.children)?void 0:o.some(({rawNode:e})=>n?n(e):e.icon);let{rawNode:t}=e;return n?n(t):t.icon})}),hasSubmenuRef:(0,d.EW)(()=>{let{value:o}=n;return e.tmNodes.some(e=>{var n;if(e.isGroup)return null==(n=e.children)?void 0:n.some(({rawNode:e})=>F(e,o));let{rawNode:t}=e;return F(t,o)})})});let t=(0,d.KR)(null);return(0,d.Gt)(S.gK,null),(0,d.Gt)(k.G,null),(0,d.Gt)(A.U,t),{bodyRef:t}},render(){let{parentKey:e,clsPrefix:o,scrollable:n}=this,t=this.tmNodes.map(t=>{let{rawNode:r}=t;return!1===r.show?null:"render"===r.type?(0,d.h)(K,{tmNode:t,key:t.key}):I(r)?(0,d.h)(C,{clsPrefix:o,key:t.key}):"group"===r.type?(0,d.h)(D,{clsPrefix:o,tmNode:t,parentKey:e,key:t.key}):(0,d.h)(_,{clsPrefix:o,tmNode:t,parentKey:e,key:t.key,props:r.props,scrollable:n})});return(0,d.h)("div",{class:[`${o}-dropdown-menu`,n&&`${o}-dropdown-menu--scrollable`],ref:"bodyRef"},n?(0,d.h)(g.b,{contentClass:`${o}-dropdown-menu__content`},{default:()=>t}):t,this.showArrow?(0,N.Uc)({clsPrefix:o,arrowStyle:this.arrowStyle,arrowClass:void 0,arrowWrapperClass:void 0,arrowWrapperStyle:void 0}):null)}});var T=n(66657);let L=(0,c.cB)("dropdown-menu",`
 transform-origin: var(--v-transform-origin);
 background-color: var(--n-color);
 border-radius: var(--n-border-radius);
 box-shadow: var(--n-box-shadow);
 position: relative;
 transition:
 background-color .3s var(--n-bezier),
 box-shadow .3s var(--n-bezier);
`,[(0,T.S)(),(0,c.cB)("dropdown-option",`
 position: relative;
 `,[(0,c.c)("a",`
 text-decoration: none;
 color: inherit;
 outline: none;
 `,[(0,c.c)("&::before",`
 content: "";
 position: absolute;
 left: 0;
 right: 0;
 top: 0;
 bottom: 0;
 `)]),(0,c.cB)("dropdown-option-body",`
 display: flex;
 cursor: pointer;
 position: relative;
 height: var(--n-option-height);
 line-height: var(--n-option-height);
 font-size: var(--n-font-size);
 color: var(--n-option-text-color);
 transition: color .3s var(--n-bezier);
 `,[(0,c.c)("&::before",`
 content: "";
 position: absolute;
 top: 0;
 bottom: 0;
 left: 4px;
 right: 4px;
 transition: background-color .3s var(--n-bezier);
 border-radius: var(--n-border-radius);
 `),(0,c.C5)("disabled",[(0,c.cM)("pending",`
 color: var(--n-option-text-color-hover);
 `,[(0,c.cE)("prefix, suffix",`
 color: var(--n-option-text-color-hover);
 `),(0,c.c)("&::before","background-color: var(--n-option-color-hover);")]),(0,c.cM)("active",`
 color: var(--n-option-text-color-active);
 `,[(0,c.cE)("prefix, suffix",`
 color: var(--n-option-text-color-active);
 `),(0,c.c)("&::before","background-color: var(--n-option-color-active);")]),(0,c.cM)("child-active",`
 color: var(--n-option-text-color-child-active);
 `,[(0,c.cE)("prefix, suffix",`
 color: var(--n-option-text-color-child-active);
 `)])]),(0,c.cM)("disabled",`
 cursor: not-allowed;
 opacity: var(--n-option-opacity-disabled);
 `),(0,c.cM)("group",`
 font-size: calc(var(--n-font-size) - 1px);
 color: var(--n-group-header-text-color);
 `,[(0,c.cE)("prefix",`
 width: calc(var(--n-option-prefix-width) / 2);
 `,[(0,c.cM)("show-icon",`
 width: calc(var(--n-option-icon-prefix-width) / 2);
 `)])]),(0,c.cE)("prefix",`
 width: var(--n-option-prefix-width);
 display: flex;
 justify-content: center;
 align-items: center;
 color: var(--n-prefix-color);
 transition: color .3s var(--n-bezier);
 z-index: 1;
 `,[(0,c.cM)("show-icon",`
 width: var(--n-option-icon-prefix-width);
 `),(0,c.cB)("icon",`
 font-size: var(--n-option-icon-size);
 `)]),(0,c.cE)("label",`
 white-space: nowrap;
 flex: 1;
 z-index: 1;
 `),(0,c.cE)("suffix",`
 box-sizing: border-box;
 flex-grow: 0;
 flex-shrink: 0;
 display: flex;
 justify-content: flex-end;
 align-items: center;
 min-width: var(--n-option-suffix-width);
 padding: 0 8px;
 transition: color .3s var(--n-bezier);
 color: var(--n-suffix-color);
 z-index: 1;
 `,[(0,c.cM)("has-submenu",`
 width: var(--n-option-icon-suffix-width);
 `),(0,c.cB)("icon",`
 font-size: var(--n-option-icon-size);
 `)]),(0,c.cB)("dropdown-menu","pointer-events: all;")]),(0,c.cB)("dropdown-offset-container",`
 pointer-events: none;
 position: absolute;
 left: 0;
 right: 0;
 top: -4px;
 bottom: -4px;
 `)]),(0,c.cB)("dropdown-divider",`
 transition: background-color .3s var(--n-bezier);
 background-color: var(--n-divider-color);
 height: 1px;
 margin: 4px 0;
 `),(0,c.cB)("dropdown-menu-wrapper",`
 transform-origin: var(--v-transform-origin);
 width: fit-content;
 `),(0,c.c)(">",[(0,c.cB)("scrollbar",`
 height: inherit;
 max-height: inherit;
 `)]),(0,c.C5)("scrollable",`
 padding: var(--n-padding);
 `),(0,c.cM)("scrollable",[(0,c.cE)("content",`
 padding: var(--n-padding);
 `)])]),G=Object.keys(f.vY),H=Object.assign(Object.assign(Object.assign({},f.vY),{animated:{type:Boolean,default:!0},keyboard:{type:Boolean,default:!0},size:{type:String,default:"medium"},inverted:Boolean,placement:{type:String,default:"bottom"},onSelect:[Function,Array],options:{type:Array,default:()=>[]},menuProps:Function,showArrow:Boolean,renderLabel:Function,renderIcon:Function,renderOption:Function,nodeProps:Function,labelField:{type:String,default:"label"},keyField:{type:String,default:"key"},childrenField:{type:String,default:"children"},value:[String,Number]}),a.A.props),q=(0,d.pM)({name:"Dropdown",inheritAttrs:!1,props:H,setup(e){let o=(0,d.KR)(!1),n=(0,r.A)((0,d.lW)(e,"show"),o),h=(0,d.EW)(()=>{let{keyField:o,childrenField:n}=e;return(0,t.G)(e.options,{getKey:e=>e[o],getDisabled:e=>!0===e.disabled,getIgnored:e=>"divider"===e.type||"render"===e.type,getChildren:e=>e[n]})}),v=(0,d.EW)(()=>h.value.treeNodes),f=(0,d.KR)(null),b=(0,d.KR)(null),m=(0,d.KR)(null),x=(0,d.EW)(()=>{var e,o,n;return null!=(n=null!=(o=null!=(e=f.value)?e:b.value)?o:m.value)?n:null}),g=(0,d.EW)(()=>h.value.getPath(x.value).keyPath),k=(0,d.EW)(()=>h.value.getPath(e.value).keyPath),S=(0,i.A)(()=>e.keyboard&&n.value);(0,l.A)({keydown:{ArrowUp:{prevent:!0,handler:function(){M("up")}},ArrowRight:{prevent:!0,handler:function(){M("right")}},ArrowDown:{prevent:!0,handler:function(){M("down")}},ArrowLeft:{prevent:!0,handler:function(){M("left")}},Enter:{prevent:!0,handler:function(){let e=$();(null==e?void 0:e.isLeaf)&&n.value&&(W(e.key,e.rawNode),P(!1))}},Escape:function(){P(!1)}}},S);let{mergedClsPrefixRef:A,inlineThemeDisabled:N}=(0,s.Ay)(e),C=(0,a.A)("Dropdown","-dropdown",L,w.A,e,A);function W(o,n){let{onSelect:t}=e;t&&(0,p.T)(t,o,n)}function P(n){let{"onUpdate:show":t,onUpdateShow:r}=e;t&&(0,p.T)(t,n),r&&(0,p.T)(r,n),o.value=n}function E(){f.value=null,b.value=null,m.value=null}function $(){var e;let{value:o}=h,{value:n}=x;return o&&null!==n&&null!=(e=o.getNode(n))?e:null}function M(e){let{value:o}=x,{value:{getFirstAvailableNode:n}}=h,t=null;if(null===o){let e=n();null!==e&&(t=e.key)}else{let o=$();if(o){let n;switch(e){case"down":n=o.getNext();break;case"up":n=o.getPrev();break;case"right":n=o.getChild();break;case"left":n=o.getParent()}n&&(t=n.key)}}null!==t&&(f.value=null,b.value=t)}(0,d.Gt)(y,{labelFieldRef:(0,d.lW)(e,"labelField"),childrenFieldRef:(0,d.lW)(e,"childrenField"),renderLabelRef:(0,d.lW)(e,"renderLabel"),renderIconRef:(0,d.lW)(e,"renderIcon"),hoverKeyRef:f,keyboardKeyRef:b,lastToggledSubmenuKeyRef:m,pendingKeyPathRef:g,activeKeyPathRef:k,animatedRef:(0,d.lW)(e,"animated"),mergedShowRef:n,nodePropsRef:(0,d.lW)(e,"nodeProps"),renderOptionRef:(0,d.lW)(e,"renderOption"),menuPropsRef:(0,d.lW)(e,"menuProps"),doSelect:W,doUpdateShow:P}),(0,d.wB)(n,o=>{e.animated||o||E()});let R=(0,d.EW)(()=>{let{size:o,inverted:n}=e,{common:{cubicBezierEaseInOut:t},self:r}=C.value,{padding:i,dividerColor:l,borderRadius:d,optionOpacityDisabled:a,[(0,c.cF)("optionIconSuffixWidth",o)]:s,[(0,c.cF)("optionSuffixWidth",o)]:u,[(0,c.cF)("optionIconPrefixWidth",o)]:p,[(0,c.cF)("optionPrefixWidth",o)]:h,[(0,c.cF)("fontSize",o)]:v,[(0,c.cF)("optionHeight",o)]:f,[(0,c.cF)("optionIconSize",o)]:w}=r,b={"--n-bezier":t,"--n-font-size":v,"--n-padding":i,"--n-border-radius":d,"--n-option-height":f,"--n-option-prefix-width":h,"--n-option-icon-prefix-width":p,"--n-option-suffix-width":u,"--n-option-icon-suffix-width":s,"--n-option-icon-size":w,"--n-divider-color":l,"--n-option-opacity-disabled":a};return n?(b["--n-color"]=r.colorInverted,b["--n-option-color-hover"]=r.optionColorHoverInverted,b["--n-option-color-active"]=r.optionColorActiveInverted,b["--n-option-text-color"]=r.optionTextColorInverted,b["--n-option-text-color-hover"]=r.optionTextColorHoverInverted,b["--n-option-text-color-active"]=r.optionTextColorActiveInverted,b["--n-option-text-color-child-active"]=r.optionTextColorChildActiveInverted,b["--n-prefix-color"]=r.prefixColorInverted,b["--n-suffix-color"]=r.suffixColorInverted,b["--n-group-header-text-color"]=r.groupHeaderTextColorInverted):(b["--n-color"]=r.color,b["--n-option-color-hover"]=r.optionColorHover,b["--n-option-color-active"]=r.optionColorActive,b["--n-option-text-color"]=r.optionTextColor,b["--n-option-text-color-hover"]=r.optionTextColorHover,b["--n-option-text-color-active"]=r.optionTextColorActive,b["--n-option-text-color-child-active"]=r.optionTextColorChildActive,b["--n-prefix-color"]=r.prefixColor,b["--n-suffix-color"]=r.suffixColor,b["--n-group-header-text-color"]=r.groupHeaderTextColor),b}),B=N?(0,u.R)("dropdown",(0,d.EW)(()=>`${e.size[0]}${e.inverted?"i":""}`),R,e):void 0;return{mergedClsPrefix:A,mergedTheme:C,tmNodes:v,mergedShow:n,handleAfterLeave:()=>{e.animated&&E()},doUpdateShow:P,cssVars:N?void 0:R,themeClass:null==B?void 0:B.themeClass,onRender:null==B?void 0:B.onRender}},render(){let e=(e,o,n,t,r)=>{var i;let{mergedClsPrefix:l,menuProps:a}=this;null==(i=this.onRender)||i.call(this);let s=(null==a?void 0:a(void 0,this.tmNodes.map(e=>e.rawNode)))||{},u={ref:(0,h.V)(o),class:[e,`${l}-dropdown`,this.themeClass],clsPrefix:l,tmNodes:this.tmNodes,style:[...n,this.cssVars],showArrow:this.showArrow,arrowStyle:this.arrowStyle,scrollable:this.scrollable,onMouseenter:t,onMouseleave:r};return(0,d.h)(j,(0,d.v6)(this.$attrs,u,s))},{mergedTheme:o}=this,n={show:this.mergedShow,theme:o.peers.Popover,themeOverrides:o.peerOverrides.Popover,internalOnAfterLeave:this.handleAfterLeave,internalRenderBody:e,onUpdateShow:this.doUpdateShow,"onUpdate:show":void 0};return(0,d.h)(f.Ay,Object.assign({},(0,v.a)(this.$props,G),n),{trigger:()=>{var e,o;return null==(o=(e=this.$slots).default)?void 0:o.call(e)}})}})}}]);