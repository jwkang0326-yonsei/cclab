import{w as c}from"./with-props-CP8Fb9K_.js";import{g as i,j as e,F as o}from"./chunk-LSOULM7L-CE8sSiXH.js";import{B as a}from"./button-ZU_4EZ5Z.js";import{c as r}from"./createLucideIcon-ClctZlHb.js";/**
 * @license lucide-react v0.482.0 - ISC
 *
 * This source code is licensed under the ISC license.
 * See the LICENSE file in the root directory of this source tree.
 */const l=[["circle",{cx:"12",cy:"12",r:"10",key:"1mglay"}],["path",{d:"m9 12 2 2 4-4",key:"dzmm74"}]],m=r("CircleCheck",l);/**
 * @license lucide-react v0.482.0 - ISC
 *
 * This source code is licensed under the ISC license.
 * See the LICENSE file in the root directory of this source tree.
 */const d=[["path",{d:"M21 12a9 9 0 1 1-6.219-8.56",key:"13zald"}]],g=r("LoaderCircle",d);function u(s,t){return window.gtag&&window.gtag("event",s,t)}const y=()=>[{title:"Google Tag Test | undefined"}];async function j(){return u("test_event",{test:"test",time:new Date().toISOString()}),{success:!0}}const w=c(function({actionData:t}){const{state:n}=i();return e.jsxs("div",{className:"flex h-screen flex-col items-center justify-center gap-2 px-5 py-10 md:px-10 md:py-20",children:[e.jsx("h1",{className:"text-2xl font-semibold",children:"Google Tag Test"}),e.jsx("p",{className:"text-muted-foreground text-center",children:"Test that the Google Tag integration is working by clicking the button below."}),e.jsx(o,{method:"post",className:"mt-5 flex w-xs justify-center",children:e.jsx(a,{disabled:n==="submitting",type:"submit",className:"w-1/2",children:n==="submitting"?e.jsx(e.Fragment,{children:e.jsx(g,{className:"size-4 animate-spin"})}):"Trigger Event"})}),(t==null?void 0:t.success)&&e.jsxs("p",{className:"text-muted-foreground flex items-center gap-2",children:[e.jsx(m,{className:"size-4 text-green-600"})," Event triggered successfully"]})]})});export{j as clientAction,w as default,y as meta};
