import{w as i}from"./with-props-CP8Fb9K_.js";import{j as e,L as l,r as o}from"./chunk-LSOULM7L-CE8sSiXH.js";import{B as c}from"./button-ZU_4EZ5Z.js";import{U as d}from"./users-CoGeGUwu.js";import{c as a}from"./createLucideIcon-ClctZlHb.js";import{b as m}from"./groups-BdBlsHh2.js";import"./firebase-3OE0PJgJ.js";/**
 * @license lucide-react v0.482.0 - ISC
 *
 * This source code is licensed under the ISC license.
 * See the LICENSE file in the root directory of this source tree.
 */const x=[["path",{d:"M5 12h14",key:"1ays0h"}],["path",{d:"m12 5 7 7-7 7",key:"xquz4c"}]],u=a("ArrowRight",x);/**
 * @license lucide-react v0.482.0 - ISC
 *
 * This source code is licensed under the ISC license.
 * See the LICENSE file in the root directory of this source tree.
 */const h=[["path",{d:"M5 12h14",key:"1ays0h"}],["path",{d:"M12 5v14",key:"s699le"}]],p=a("Plus",h);/**
 * @license lucide-react v0.482.0 - ISC
 *
 * This source code is licensed under the ISC license.
 * See the LICENSE file in the root directory of this source tree.
 */const f=[["path",{d:"M19 21v-2a4 4 0 0 0-4-4H9a4 4 0 0 0-4 4v2",key:"975kel"}],["circle",{cx:"12",cy:"7",r:"4",key:"17ys0d"}]],j=a("User",f);function g({id:n,name:t,leaderName:r,memberCount:s}){return e.jsxs("div",{className:"rounded-lg border bg-card text-card-foreground shadow-sm p-6 flex flex-col justify-between h-[180px]",children:[e.jsxs("div",{children:[e.jsxs("div",{className:"flex items-center justify-between",children:[e.jsx("h3",{className:"text-xl font-bold tracking-tight",children:t}),e.jsxs("div",{className:"bg-primary/10 text-primary px-2.5 py-0.5 rounded-full text-xs font-medium flex items-center gap-1",children:[e.jsx(d,{className:"h-3 w-3"}),s]})]}),e.jsxs("div",{className:"mt-4 flex items-center gap-2 text-sm text-muted-foreground",children:[e.jsx(j,{className:"h-4 w-4"}),e.jsxs("span",{children:["Leader: ",e.jsx("span",{className:"font-medium text-foreground",children:r})]})]})]}),e.jsx("div",{className:"mt-4",children:e.jsx(c,{asChild:!0,variant:"outline",className:"w-full justify-between group",children:e.jsxs(l,{to:`/groups/${n}`,children:["Manage Group",e.jsx(u,{className:"h-4 w-4 ml-2 transition-transform group-hover:translate-x-1"})]})})})]})}const C=()=>[{title:"Groups | Admin Web"}],L=i(function(){const[t,r]=o.useState([]);return o.useEffect(()=>{m().then(r)},[]),e.jsxs("div",{className:"flex-1 space-y-8 p-8 pt-6",children:[e.jsxs("div",{className:"flex items-center justify-between space-y-2",children:[e.jsxs("div",{children:[e.jsx("h2",{className:"text-3xl font-bold tracking-tight",children:"Small Groups"}),e.jsx("p",{className:"text-muted-foreground",children:"Manage your church cells and groups here."})]}),e.jsx("div",{className:"flex items-center space-x-2",children:e.jsxs(c,{children:[e.jsx(p,{className:"mr-2 h-4 w-4"})," Create Group"]})})]}),e.jsx("div",{className:"grid gap-6 md:grid-cols-2 lg:grid-cols-3 xl:grid-cols-4",children:t.length===0?e.jsx("p",{className:"text-muted-foreground col-span-full",children:"No groups found."}):t.map(s=>e.jsx(g,{id:s.id,name:s.name,leaderName:s.leaderName,memberCount:s.memberCount},s.id))})]})});export{L as default,C as meta};
