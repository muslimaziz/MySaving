import { FormEvent, ReactNode, useEffect, useMemo, useRef, useState } from "react";

type Screen = "home" | "targets" | "profile" | "target-form" | "detail" | "saving-form" | "history";
type IconName =
  | "home" | "target" | "user" | "plus" | "arrow" | "more" | "calendar"
  | "wallet" | "trend" | "check" | "clock" | "edit" | "trash" | "image"
  | "bell" | "moon" | "database" | "info" | "chevron" | "sparkles" | "close";

type Transaction = { id: string; amount: number; date: string; note: string };
type SavingTarget = {
  id: string;
  name: string;
  price: number;
  date: string;
  note: string;
  image: string;
  transactions: Transaction[];
};

const demoTargets: SavingTarget[] = [
  {
    id: "laptop",
    name: "MacBook untuk kuliah",
    price: 18000000,
    date: "2026-12-30",
    note: "Laptop baru untuk tugas kuliah dan freelance.",
    image: "https://images.unsplash.com/photo-1449247709967-d4461a6a6103?crop=entropy&cs=tinysrgb&fit=crop&fm=jpg&q=80&w=900",
    transactions: [
      { id: "t1", amount: 2500000, date: "2026-06-12", note: "Bonus project" },
      { id: "t2", amount: 1000000, date: "2026-05-28", note: "Tabungan bulanan" },
      { id: "t3", amount: 500000, date: "2026-05-05", note: "Tabungan mingguan" },
    ],
  },
  {
    id: "liburan",
    name: "Liburan ke Bali",
    price: 7500000,
    date: "2026-10-15",
    note: "Staycation 5 hari bersama sahabat.",
    image: "",
    transactions: [
      { id: "t4", amount: 4000000, date: "2026-06-01", note: "THR" },
      { id: "t5", amount: 2250000, date: "2026-04-20", note: "Tabungan rutin" },
      { id: "t6", amount: 1250000, date: "2026-03-20", note: "Tabungan rutin" },
    ],
  },
];

const rupiah = (value: number) =>
  new Intl.NumberFormat("id-ID", { style: "currency", currency: "IDR", maximumFractionDigits: 0 }).format(value);

const shortRupiah = (value: number) => {
  if (value >= 1000000) return `Rp${(value / 1000000).toLocaleString("id-ID", { maximumFractionDigits: 1 })} jt`;
  if (value >= 1000) return `Rp${Math.round(value / 1000)} rb`;
  return rupiah(value);
};

const prettyDate = (date: string) =>
  date ? new Intl.DateTimeFormat("id-ID", { day: "numeric", month: "long", year: "numeric" }).format(new Date(`${date}T00:00:00`)) : "—";

const getSaved = (target: SavingTarget) => target.transactions.reduce((sum, item) => sum + item.amount, 0);
const getProgress = (target: SavingTarget) => Math.min(100, Math.round((getSaved(target) / target.price) * 100));

function Icon({ name, size = 20, strokeWidth = 1.8 }: { name: IconName; size?: number; strokeWidth?: number }) {
  const paths: Record<IconName, ReactNode> = {
    home: <><path d="m3 10 9-7 9 7" /><path d="M5 9v11h14V9M9 20v-6h6v6" /></>,
    target: <><circle cx="12" cy="12" r="9" /><circle cx="12" cy="12" r="5" /><circle cx="12" cy="12" r="1.5" /></>,
    user: <><circle cx="12" cy="8" r="4" /><path d="M4.5 21a7.5 7.5 0 0 1 15 0" /></>,
    plus: <><path d="M12 5v14M5 12h14" /></>,
    arrow: <><path d="m15 18-6-6 6-6" /></>,
    more: <><circle cx="5" cy="12" r="1" fill="currentColor" /><circle cx="12" cy="12" r="1" fill="currentColor" /><circle cx="19" cy="12" r="1" fill="currentColor" /></>,
    calendar: <><path d="M6 3v3m12-3v3M4 9h16M5 5h14a1 1 0 0 1 1 1v14H4V6a1 1 0 0 1 1-1Z" /></>,
    wallet: <><path d="M4 6h15a1 1 0 0 1 1 1v12H4a2 2 0 0 1-2-2V6a3 3 0 0 1 3-3h12v3" /><path d="M15 11h7v5h-7a2.5 2.5 0 0 1 0-5Z" /></>,
    trend: <><path d="m4 17 5-5 4 3 7-8" /><path d="M15 7h5v5" /></>,
    check: <path d="m5 12 4 4L19 6" />,
    clock: <><circle cx="12" cy="12" r="9" /><path d="M12 7v5l3 2" /></>,
    edit: <><path d="m14 5 5 5M4 20l3.5-.7L19 7.8a2.1 2.1 0 0 0-3-3L4.7 16.2 4 20Z" /></>,
    trash: <><path d="M4 7h16M9 7V4h6v3m3 0-1 14H7L6 7m4 4v6m4-6v6" /></>,
    image: <><rect x="3" y="4" width="18" height="16" rx="2" /><circle cx="8.5" cy="9" r="1.5" /><path d="m4 17 5-5 4 4 3-3 5 5" /></>,
    bell: <><path d="M18 9a6 6 0 0 0-12 0c0 7-3 7-3 9h18c0-2-3-2-3-9" /><path d="M10 21h4" /></>,
    moon: <path d="M20 15.5A9 9 0 0 1 8.5 4 9 9 0 1 0 20 15.5Z" />,
    database: <><ellipse cx="12" cy="5" rx="8" ry="3" /><path d="M4 5v6c0 1.7 3.6 3 8 3s8-1.3 8-3V5M4 11v6c0 1.7 3.6 3 8 3s8-1.3 8-3v-6" /></>,
    info: <><circle cx="12" cy="12" r="9" /><path d="M12 11v6M12 7h.01" /></>,
    chevron: <path d="m9 18 6-6-6-6" />,
    sparkles: <><path d="m12 3 1.2 3.8L17 8l-3.8 1.2L12 13l-1.2-3.8L7 8l3.8-1.2L12 3Z" /><path d="m19 14 .7 2.3L22 17l-2.3.7L19 20l-.7-2.3L16 17l2.3-.7L19 14ZM5 13l.7 2.3L8 16l-2.3.7L5 19l-.7-2.3L2 16l2.3-.7L5 13Z" /></>,
    close: <path d="m6 6 12 12M18 6 6 18" />,
  };
  return <svg width={size} height={size} viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth={strokeWidth} strokeLinecap="round" strokeLinejoin="round" aria-hidden>{paths[name]}</svg>;
}

function Button({ children, onClick, type = "button", kind = "primary", className = "", disabled = false }: {
  children: ReactNode; onClick?: () => void; type?: "button" | "submit"; kind?: "primary" | "secondary" | "ghost" | "danger"; className?: string; disabled?: boolean;
}) {
  const styles = {
    primary: "bg-[#203f36] text-white shadow-[0_8px_20px_rgba(32,63,54,.2)] hover:bg-[#163129]",
    secondary: "bg-[#e2eee8] text-[#203f36] hover:bg-[#d3e5dc]",
    ghost: "bg-transparent text-[#56645f] hover:bg-[#edf3ef]",
    danger: "bg-[#fff0ec] text-[#b74833] hover:bg-[#ffe2dc]",
  };
  return <button type={type} disabled={disabled} onClick={onClick} className={`inline-flex min-h-12 items-center justify-center gap-2 rounded-2xl px-5 text-sm font-bold transition active:scale-[.98] disabled:opacity-50 ${styles[kind]} ${className}`}>{children}</button>;
}

function Progress({ value, light = false }: { value: number; light?: boolean }) {
  return <div className={`h-2 overflow-hidden rounded-full ${light ? "bg-white/20" : "bg-[#e6ebe8]"}`}><div className={`h-full rounded-full transition-all duration-700 ${light ? "bg-[#d8f29e]" : "bg-[#e7a84b]"}`} style={{ width: `${value}%` }} /></div>;
}

function BottomNav({ screen, go }: { screen: Screen; go: (screen: Screen) => void }) {
  const tabs: { screen: Screen; icon: IconName; label: string }[] = [
    { screen: "home", icon: "home", label: "Beranda" },
    { screen: "targets", icon: "target", label: "Target" },
    { screen: "profile", icon: "user", label: "Profil" },
  ];
  return <nav className="fixed bottom-0 left-1/2 z-40 flex w-full max-w-[460px] -translate-x-1/2 items-center justify-around border-t border-[#e5e9e7] bg-[#fbfcfa]/95 px-6 pb-[max(14px,env(safe-area-inset-bottom))] pt-3 backdrop-blur-xl">
    {tabs.map(tab => {
      const active = screen === tab.screen || (tab.screen === "targets" && ["detail", "history"].includes(screen));
      return <button key={tab.screen} onClick={() => go(tab.screen)} className={`relative flex min-w-16 flex-col items-center gap-1 text-[11px] font-semibold transition ${active ? "text-[#203f36]" : "text-[#9aa39f]"}`}>
        {active && <span className="absolute -top-3 h-1 w-8 rounded-b-full bg-[#e7a84b]" />}
        <Icon name={tab.icon} size={22} strokeWidth={active ? 2.3 : 1.8} />
        {tab.label}
      </button>;
    })}
  </nav>;
}

function PageHeader({ title, onBack, right }: { title: string; onBack?: () => void; right?: ReactNode }) {
  return <header className="sticky top-0 z-30 flex h-18 items-center justify-between bg-[#f7f8f5]/90 px-5 backdrop-blur-xl">
    <div className="w-10">{onBack && <button aria-label="Kembali" onClick={onBack} className="grid size-10 place-items-center rounded-full bg-white text-[#203f36] shadow-sm"><Icon name="arrow" /></button>}</div>
    <div className="text-[17px] font-bold text-[#1b2d27]">{title}</div>
    <div className="flex w-10 justify-end">{right}</div>
  </header>;
}

function TargetCard({ target, onClick }: { target: SavingTarget; onClick: () => void }) {
  const saved = getSaved(target);
  const progress = getProgress(target);
  const completed = progress >= 100;
  return <button onClick={onClick} className="group w-full rounded-[26px] bg-white p-3 text-left shadow-[0_10px_35px_rgba(38,58,49,.06)] ring-1 ring-black/[.025] transition hover:-translate-y-0.5 hover:shadow-[0_16px_40px_rgba(38,58,49,.1)]">
    <div className="flex gap-3.5">
      <div className="relative h-28 w-28 shrink-0 overflow-hidden rounded-[20px] bg-[#e4efe9]">
        {target.image ? <img src={target.image} alt="" className="h-full w-full object-cover transition duration-500 group-hover:scale-105" /> :
          <div className="grid h-full place-items-center bg-gradient-to-br from-[#e7efe7] to-[#c9ddce] text-[#46685b]"><Icon name={target.id.includes("liburan") ? "sparkles" : "target"} size={36} /></div>}
        <span className={`absolute left-2 top-2 rounded-full px-2.5 py-1 text-[9px] font-extrabold uppercase tracking-wide ${completed ? "bg-[#dff3ce] text-[#396023]" : "bg-white/90 text-[#4c5d57]"}`}>{completed ? "Selesai" : "Aktif"}</span>
      </div>
      <div className="flex min-w-0 flex-1 flex-col py-1">
        <div className="mb-1 truncate text-[15px] font-bold text-[#1d2d28]">{target.name}</div>
        <div className="mb-3 flex items-center gap-1.5 text-[11px] text-[#8a9590]"><Icon name="calendar" size={13} /> {prettyDate(target.date)}</div>
        <div className="mb-2 flex items-end justify-between gap-2">
          <div><span className="text-[14px] font-extrabold text-[#29483e]">{shortRupiah(saved)}</span><span className="text-[10px] text-[#9aa39f]"> / {shortRupiah(target.price)}</span></div>
          <span className="text-xs font-extrabold text-[#d7922f]">{progress}%</span>
        </div>
        <Progress value={progress} />
      </div>
    </div>
  </button>;
}

function EmptyState({ onCreate }: { onCreate: () => void }) {
  return <div className="mx-5 mt-5 flex flex-col items-center rounded-[30px] bg-white px-8 py-12 text-center shadow-[0_12px_40px_rgba(38,58,49,.06)]">
    <div className="relative mb-7 grid size-28 place-items-center rounded-full bg-[#edf4ed] text-[#315448]">
      <div className="absolute -right-1 top-1 grid size-9 place-items-center rounded-full bg-[#f4c979] text-[#6b4a18]"><Icon name="plus" size={18} /></div>
      <Icon name="wallet" size={50} strokeWidth={1.4} />
    </div>
    <div className="text-xl font-extrabold text-[#1b2d27]">Mulai tujuan pertamamu</div>
    <p className="mt-2 max-w-64 text-sm leading-6 text-[#7c8883]">Punya sesuatu yang kamu impikan? Buat target dan mulai menabung sedikit demi sedikit.</p>
    <Button onClick={onCreate} className="mt-7 w-full"><Icon name="plus" size={18} /> Buat Target</Button>
  </div>;
}

function Home({ targets, go, openTarget }: { targets: SavingTarget[]; go: (s: Screen) => void; openTarget: (id: string) => void }) {
  const total = targets.reduce((sum, target) => sum + getSaved(target), 0);
  const active = targets.filter(target => getProgress(target) < 100);
  return <div className="pb-28">
    <section className="rounded-b-[40px] bg-[#203f36] px-5 pb-7 pt-7 text-white">
      <div className="flex items-center justify-between">
        <div><p className="text-xs font-medium text-white/60">Selamat datang,</p><div className="mt-1 text-xl font-extrabold">Halo, Nadia!</div></div>
        <button onClick={() => go("profile")} className="grid size-11 place-items-center rounded-full bg-[#f0c575] text-[#3e3a24] ring-4 ring-white/10"><span className="text-sm font-extrabold">N</span></button>
      </div>
      <div className="mt-8 rounded-[28px] bg-white/[.09] p-5 ring-1 ring-white/10 backdrop-blur-sm">
        <div className="flex items-start justify-between">
          <div><p className="text-xs text-white/60">Total tabunganmu</p><div className="mt-2 text-[29px] font-extrabold tracking-tight">{rupiah(total)}</div></div>
          <div className="grid size-10 place-items-center rounded-2xl bg-[#d8f29e] text-[#203f36]"><Icon name="wallet" /></div>
        </div>
        <div className="mt-5 flex items-center gap-2 border-t border-white/10 pt-4 text-xs text-white/70">
          <span className="inline-flex items-center gap-1.5 font-bold text-[#d8f29e]"><Icon name="trend" size={15} /> Tetap semangat</span>
          <span>•</span><span>{active.length} target aktif</span>
        </div>
      </div>
    </section>
    {targets.length === 0 ? <EmptyState onCreate={() => go("target-form")} /> : <>
      <section className="px-5 pt-7">
        <div className="mb-4 flex items-center justify-between">
          <div><div className="text-lg font-extrabold text-[#1b2d27]">Target tabungan</div><p className="mt-0.5 text-xs text-[#8a9590]">Selangkah lebih dekat setiap hari</p></div>
          <button onClick={() => go("targets")} className="text-xs font-bold text-[#315448]">Lihat semua</button>
        </div>
        <div className="space-y-3">{targets.slice(0, 3).map(target => <TargetCard key={target.id} target={target} onClick={() => openTarget(target.id)} />)}</div>
      </section>
      <button onClick={() => go("target-form")} className="mx-5 mt-5 flex w-[calc(100%-40px)] items-center gap-3 rounded-[22px] border border-dashed border-[#9db3aa] bg-[#eff5f1]/60 p-4 text-left text-[#315448] transition hover:bg-[#e5f0e9]">
        <span className="grid size-10 place-items-center rounded-2xl bg-white shadow-sm"><Icon name="plus" /></span>
        <span><span className="block text-sm font-bold">Buat target baru</span><span className="text-[11px] text-[#7c8883]">Ubah impian jadi rencana nyata</span></span>
      </button>
    </>}
  </div>;
}

function Targets({ targets, go, openTarget }: { targets: SavingTarget[]; go: (s: Screen) => void; openTarget: (id: string) => void }) {
  const [filter, setFilter] = useState<"all" | "active" | "done">("all");
  const filtered = targets.filter(t => filter === "all" || (filter === "done" ? getProgress(t) >= 100 : getProgress(t) < 100));
  return <div className="pb-28">
    <PageHeader title="Target Saya" right={<button onClick={() => go("target-form")} className="grid size-10 place-items-center rounded-full bg-[#203f36] text-white"><Icon name="plus" /></button>} />
    <main className="px-5">
      <div className="mt-2 rounded-[26px] bg-[#e7a84b] p-5 text-[#3f2e13]">
        <div className="flex items-center justify-between"><div><p className="text-xs font-semibold opacity-65">Total impian</p><div className="mt-1 text-2xl font-extrabold">{targets.length} target</div></div><div className="grid size-12 place-items-center rounded-2xl bg-white/25"><Icon name="target" size={27} /></div></div>
      </div>
      <div className="my-5 flex rounded-2xl bg-[#eaeeeb] p-1">
        {([["all", "Semua"], ["active", "Aktif"], ["done", "Selesai"]] as const).map(([key, label]) => <button key={key} onClick={() => setFilter(key)} className={`flex-1 rounded-xl py-2.5 text-xs font-bold transition ${filter === key ? "bg-white text-[#203f36] shadow-sm" : "text-[#89938f]"}`}>{label}</button>)}
      </div>
      {filtered.length ? <div className="space-y-3">{filtered.map(t => <TargetCard key={t.id} target={t} onClick={() => openTarget(t.id)} />)}</div> : <EmptyState onCreate={() => go("target-form")} />}
    </main>
  </div>;
}

function TargetForm({ current, onBack, onSave, onDelete }: { current?: SavingTarget; onBack: () => void; onSave: (target: SavingTarget) => void; onDelete?: () => void }) {
  const [name, setName] = useState(current?.name ?? "");
  const [price, setPrice] = useState(current?.price ? String(current.price) : "");
  const [date, setDate] = useState(current?.date ?? "");
  const [note, setNote] = useState(current?.note ?? "");
  const [image, setImage] = useState(current?.image ?? "");
  const [error, setError] = useState("");
  const fileRef = useRef<HTMLInputElement>(null);
  const handleImage = (file?: File) => {
    if (!file) return;
    const reader = new FileReader();
    reader.onload = () => setImage(String(reader.result));
    reader.readAsDataURL(file);
  };
  const submit = (event: FormEvent) => {
    event.preventDefault();
    if (!name.trim() || Number(price) <= 0 || !date) return setError("Lengkapi nama, harga, dan tanggal target.");
    onSave({ id: current?.id ?? crypto.randomUUID(), name: name.trim(), price: Number(price), date, note: note.trim(), image, transactions: current?.transactions ?? [] });
  };
  return <div className="pb-8">
    <PageHeader title={current ? "Edit Target" : "Buat Target Baru"} onBack={onBack} />
    <form onSubmit={submit} className="space-y-5 px-5 pt-3">
      <div>
        <div className="mb-2 text-xs font-bold text-[#43544e]">Gambar target <span className="font-normal text-[#9aa39f]">(opsional)</span></div>
        <button type="button" onClick={() => fileRef.current?.click()} className="relative flex h-40 w-full items-center justify-center overflow-hidden rounded-[26px] border border-dashed border-[#aebdb7] bg-[#edf3ef] text-[#5d756b]">
          {image ? <><img src={image} alt="Pratinjau target" className="h-full w-full object-cover" /><span className="absolute inset-0 grid place-items-center bg-black/25 opacity-0 transition hover:opacity-100"><span className="rounded-xl bg-white px-4 py-2 text-xs font-bold text-[#203f36]">Ganti gambar</span></span></> :
            <span className="flex flex-col items-center gap-2"><span className="grid size-11 place-items-center rounded-2xl bg-white"><Icon name="image" /></span><span className="text-xs font-bold">Pilih dari perangkat</span></span>}
        </button>
        <input ref={fileRef} type="file" accept="image/*" className="hidden" onChange={e => handleImage(e.target.files?.[0])} />
      </div>
      <Field label="Nama target" required><input value={name} onChange={e => setName(e.target.value)} placeholder="Contoh: Laptop untuk kuliah" /></Field>
      <Field label="Harga target" required prefix="Rp"><input inputMode="numeric" value={price} onChange={e => setPrice(e.target.value.replace(/\D/g, ""))} placeholder="10.000.000" /></Field>
      <Field label="Tanggal target" required><input type="date" value={date} onChange={e => setDate(e.target.value)} /></Field>
      <Field label="Catatan tambahan"><textarea value={note} onChange={e => setNote(e.target.value)} rows={4} placeholder="Ceritakan alasan atau rencanamu..." /></Field>
      {error && <div className="rounded-2xl bg-[#fff0ec] px-4 py-3 text-xs font-semibold text-[#b74833]">{error}</div>}
      <Button type="submit" className="w-full"><Icon name="check" size={18} /> {current ? "Simpan Perubahan" : "Simpan Target"}</Button>
      {current && onDelete && <Button kind="danger" onClick={onDelete} className="w-full"><Icon name="trash" size={18} /> Hapus Target</Button>}
    </form>
  </div>;
}

function Field({ label, children, required, prefix }: { label: string; children: ReactNode; required?: boolean; prefix?: string }) {
  return <label className="block">
    <span className="mb-2 block text-xs font-bold text-[#43544e]">{label}{required && <span className="text-[#d7922f]"> *</span>}</span>
    <span className="field-wrap">{prefix && <span className="pl-4 text-sm font-bold text-[#51625c]">{prefix}</span>}{children}</span>
  </label>;
}

function Detail({ target, go, edit, remove }: { target: SavingTarget; go: (s: Screen) => void; edit: () => void; remove: () => void }) {
  const [menu, setMenu] = useState(false);
  const saved = getSaved(target);
  const progress = getProgress(target);
  const recent = [...target.transactions].sort((a, b) => b.date.localeCompare(a.date)).slice(0, 3);
  return <div className="pb-28">
    <PageHeader title="Detail Target" onBack={() => go("targets")} right={<button onClick={() => setMenu(!menu)} className="grid size-10 place-items-center rounded-full bg-white text-[#203f36] shadow-sm"><Icon name="more" /></button>} />
    {menu && <div className="absolute right-5 top-16 z-40 w-52 rounded-2xl bg-white p-2 shadow-xl ring-1 ring-black/5">
      <button onClick={edit} className="flex w-full items-center gap-3 rounded-xl px-3 py-3 text-sm font-semibold text-[#344840] hover:bg-[#eff3f0]"><Icon name="edit" size={17} /> Edit target</button>
      <button onClick={remove} className="flex w-full items-center gap-3 rounded-xl px-3 py-3 text-sm font-semibold text-[#b74833] hover:bg-[#fff0ec]"><Icon name="trash" size={17} /> Hapus target</button>
    </div>}
    <main className="px-5">
      <div className="relative h-52 overflow-hidden rounded-[30px] bg-gradient-to-br from-[#dfeae4] to-[#aec9ba]">
        {target.image ? <img src={target.image} alt={target.name} className="h-full w-full object-cover" /> : <div className="grid h-full place-items-center text-[#315448]"><Icon name="target" size={60} /></div>}
        <span className={`absolute left-4 top-4 rounded-full px-3 py-1.5 text-[10px] font-extrabold uppercase tracking-wider ${progress >= 100 ? "bg-[#dff3ce] text-[#396023]" : "bg-white/90 text-[#315448]"}`}>{progress >= 100 ? "Selesai" : "Target aktif"}</span>
      </div>
      <div className="px-1 pb-2 pt-5">
        <div className="text-2xl font-extrabold leading-tight text-[#1b2d27]">{target.name}</div>
        <div className="mt-2 flex items-center gap-1.5 text-xs text-[#87928e]"><Icon name="calendar" size={14} /> Target {prettyDate(target.date)}</div>
      </div>
      <section className="mt-4 rounded-[28px] bg-[#203f36] p-5 text-white shadow-[0_14px_30px_rgba(32,63,54,.18)]">
        <div className="flex items-end justify-between"><div><p className="text-xs text-white/60">Sudah terkumpul</p><div className="mt-1 text-2xl font-extrabold">{rupiah(saved)}</div></div><span className="text-lg font-extrabold text-[#d8f29e]">{progress}%</span></div>
        <div className="my-4"><Progress value={progress} light /></div>
        <div className="flex justify-between text-[11px] text-white/60"><span>Target {rupiah(target.price)}</span><span>Kurang {rupiah(Math.max(0, target.price - saved))}</span></div>
      </section>
      {target.note && <div className="mt-5 rounded-[22px] bg-white p-4 shadow-sm"><div className="text-xs font-bold text-[#40524b]">Catatan</div><p className="mt-2 text-sm leading-6 text-[#77837e]">{target.note}</p></div>}
      <section className="mt-7">
        <div className="mb-3 flex items-center justify-between"><div className="text-base font-extrabold text-[#1b2d27]">Riwayat terbaru</div><button onClick={() => go("history")} className="text-xs font-bold text-[#315448]">Lihat semua</button></div>
        <div className="overflow-hidden rounded-[24px] bg-white shadow-sm">
          {recent.length ? recent.map((transaction, i) => <div key={transaction.id} className={`flex items-center gap-3 p-4 ${i ? "border-t border-[#eef1ef]" : ""}`}>
            <span className="grid size-10 shrink-0 place-items-center rounded-2xl bg-[#edf4ed] text-[#315448]"><Icon name="trend" size={18} /></span>
            <div className="min-w-0 flex-1"><div className="truncate text-sm font-bold text-[#293a34]">{transaction.note || "Menabung"}</div><div className="mt-0.5 text-[10px] text-[#929c98]">{prettyDate(transaction.date)}</div></div>
            <div className="text-sm font-extrabold text-[#315448]">+{shortRupiah(transaction.amount)}</div>
          </div>) : <div className="p-8 text-center text-sm text-[#8b9692]">Belum ada riwayat tabungan.</div>}
        </div>
      </section>
      <Button onClick={() => go("saving-form")} className="mt-6 w-full"><Icon name="plus" size={18} /> Tambah Tabungan</Button>
    </main>
  </div>;
}

function SavingForm({ target, transaction, onBack, onSave }: { target: SavingTarget; transaction?: Transaction; onBack: () => void; onSave: (transaction: Transaction) => void }) {
  const [amount, setAmount] = useState(transaction ? String(transaction.amount) : "");
  const [date, setDate] = useState(transaction?.date ?? new Date().toISOString().slice(0, 10));
  const [note, setNote] = useState(transaction?.note ?? "");
  const [error, setError] = useState("");
  const submit = (event: FormEvent) => {
    event.preventDefault();
    if (Number(amount) <= 0 || !date) return setError("Masukkan nominal dan tanggal yang valid.");
    onSave({ id: transaction?.id ?? crypto.randomUUID(), amount: Number(amount), date, note: note.trim() });
  };
  return <div className="pb-8">
    <PageHeader title={transaction ? "Edit Tabungan" : "Tambah Tabungan"} onBack={onBack} />
    <form onSubmit={submit} className="px-5 pt-4">
      <div className="mb-6 rounded-[24px] bg-[#e3eee8] p-4">
        <div className="text-[10px] font-bold uppercase tracking-wider text-[#76867f]">Menabung untuk</div>
        <div className="mt-1 flex items-center justify-between"><span className="font-extrabold text-[#203f36]">{target.name}</span><span className="text-xs font-bold text-[#62756d]">{getProgress(target)}%</span></div>
      </div>
      <div className="mb-7 text-center"><div className="text-xs font-semibold text-[#7f8b86]">Berapa yang kamu tabung?</div><div className="mt-3 flex items-center justify-center border-b-2 border-[#d9e1dd] pb-3"><span className="mr-2 text-xl font-bold text-[#697871]">Rp</span><input autoFocus inputMode="numeric" value={amount} onChange={e => setAmount(e.target.value.replace(/\D/g, ""))} placeholder="0" className="w-52 bg-transparent text-center text-4xl font-extrabold tracking-tight text-[#203f36] outline-none placeholder:text-[#c5ceca]" /></div>{amount && <div className="mt-2 text-xs text-[#909a96]">{rupiah(Number(amount))}</div>}</div>
      <div className="space-y-5">
        <Field label="Tanggal tabungan" required><input type="date" value={date} onChange={e => setDate(e.target.value)} /></Field>
        <Field label="Catatan"><textarea rows={3} value={note} onChange={e => setNote(e.target.value)} placeholder="Contoh: Tabungan mingguan" /></Field>
      </div>
      {error && <div className="mt-5 rounded-2xl bg-[#fff0ec] px-4 py-3 text-xs font-semibold text-[#b74833]">{error}</div>}
      <Button type="submit" className="mt-6 w-full"><Icon name="check" size={18} /> {transaction ? "Simpan Perubahan" : "Simpan Tabungan"}</Button>
    </form>
  </div>;
}

function History({ target, onBack, onEdit, onDelete }: { target: SavingTarget; onBack: () => void; onEdit: (tx: Transaction) => void; onDelete: (id: string) => void }) {
  const sorted = [...target.transactions].sort((a, b) => b.date.localeCompare(a.date));
  return <div className="pb-8">
    <PageHeader title="Riwayat Tabungan" onBack={onBack} />
    <main className="px-5 pt-3">
      <div className="rounded-[26px] bg-[#203f36] p-5 text-white"><p className="text-xs text-white/60">Total terkumpul</p><div className="mt-1 text-2xl font-extrabold">{rupiah(getSaved(target))}</div><div className="mt-4"><Progress value={getProgress(target)} light /></div></div>
      <div className="mb-3 mt-7 text-sm font-extrabold text-[#253730]">{sorted.length} transaksi</div>
      <div className="overflow-hidden rounded-[24px] bg-white shadow-sm">
        {sorted.length ? sorted.map((tx, i) => <div key={tx.id} className={`flex items-center gap-3 p-4 ${i ? "border-t border-[#eef1ef]" : ""}`}>
          <span className="grid size-10 shrink-0 place-items-center rounded-2xl bg-[#edf4ed] text-[#315448]"><Icon name="trend" size={18} /></span>
          <button onClick={() => onEdit(tx)} className="min-w-0 flex-1 text-left"><div className="truncate text-sm font-bold text-[#293a34]">{tx.note || "Menabung"}</div><div className="mt-0.5 text-[10px] text-[#929c98]">{prettyDate(tx.date)}</div></button>
          <div className="text-right"><div className="text-sm font-extrabold text-[#315448]">+{shortRupiah(tx.amount)}</div><button onClick={() => onDelete(tx.id)} className="mt-1 text-[10px] font-semibold text-[#ba604e]">Hapus</button></div>
        </div>) : <div className="p-10 text-center text-sm text-[#8b9692]">Belum ada transaksi.</div>}
      </div>
    </main>
  </div>;
}

function Profile({ targets, reset }: { targets: SavingTarget[]; reset: () => void }) {
  const [reminder, setReminder] = useState(true);
  const [dark, setDark] = useState(false);
  return <div className="pb-28">
    <PageHeader title="Profil & Pengaturan" />
    <main className="px-5 pt-2">
      <div className="flex items-center gap-4 rounded-[26px] bg-[#203f36] p-5 text-white"><div className="grid size-16 place-items-center rounded-full bg-[#f0c575] text-xl font-extrabold text-[#3e3a24]">N</div><div><div className="text-lg font-extrabold">Nadia Pratama</div><div className="mt-1 text-xs text-white/55">Penabung konsisten</div></div></div>
      <div className="mt-5 grid grid-cols-2 gap-3"><div className="rounded-[22px] bg-white p-4 shadow-sm"><div className="text-[10px] font-bold uppercase text-[#95a09b]">Target</div><div className="mt-1 text-xl font-extrabold text-[#203f36]">{targets.length}</div></div><div className="rounded-[22px] bg-white p-4 shadow-sm"><div className="text-[10px] font-bold uppercase text-[#95a09b]">Terkumpul</div><div className="mt-1 text-xl font-extrabold text-[#203f36]">{shortRupiah(targets.reduce((s, t) => s + getSaved(t), 0))}</div></div></div>
      <div className="mb-2 mt-7 px-1 text-xs font-extrabold uppercase tracking-wider text-[#929d98]">Preferensi</div>
      <div className="overflow-hidden rounded-[24px] bg-white shadow-sm">
        <Setting icon="bell" title="Pengingat menabung" subtitle="Setiap Senin, 08.00" toggle={reminder} onToggle={() => setReminder(!reminder)} />
        <Setting icon="moon" title="Mode gelap" subtitle="Segera tersedia" toggle={dark} onToggle={() => setDark(!dark)} />
        <Setting icon="database" title="Kelola data" subtitle="Data tersimpan di perangkat" onClick={reset} />
      </div>
      <div className="mb-2 mt-7 px-1 text-xs font-extrabold uppercase tracking-wider text-[#929d98]">Tentang</div>
      <div className="overflow-hidden rounded-[24px] bg-white shadow-sm"><Setting icon="info" title="Tentang MySaving" subtitle="Versi 1.0.0 • Offline" /></div>
      <p className="mt-8 text-center text-[11px] leading-5 text-[#a0aaa5]">Dibuat untuk membantu impianmu<br />jadi lebih dekat.</p>
    </main>
  </div>;
}

function Setting({ icon, title, subtitle, toggle, onToggle, onClick }: { icon: IconName; title: string; subtitle: string; toggle?: boolean; onToggle?: () => void; onClick?: () => void }) {
  return <button onClick={onToggle ?? onClick} className="flex w-full items-center gap-3 border-b border-[#eef1ef] p-4 text-left last:border-0">
    <span className="grid size-10 shrink-0 place-items-center rounded-2xl bg-[#edf4ed] text-[#315448]"><Icon name={icon} size={19} /></span>
    <span className="flex-1"><span className="block text-sm font-bold text-[#2b3d36]">{title}</span><span className="mt-0.5 block text-[10px] text-[#929c98]">{subtitle}</span></span>
    {onToggle ? <span className={`flex h-6 w-11 items-center rounded-full p-0.5 transition ${toggle ? "justify-end bg-[#315448]" : "justify-start bg-[#cdd5d1]"}`}><span className="size-5 rounded-full bg-white shadow-sm" /></span> : <Icon name="chevron" size={17} />}
  </button>;
}

export default function App() {
  const [splash, setSplash] = useState(true);
  const [screen, setScreen] = useState<Screen>("home");
  const [targets, setTargets] = useState<SavingTarget[]>(() => {
    try {
      const stored = localStorage.getItem("mysaving-targets");
      return stored ? JSON.parse(stored) : demoTargets;
    } catch { return demoTargets; }
  });
  const [selectedId, setSelectedId] = useState<string>(targets[0]?.id ?? "");
  const [editingTarget, setEditingTarget] = useState(false);
  const [editingTransaction, setEditingTransaction] = useState<Transaction | undefined>();
  const selected = useMemo(() => targets.find(target => target.id === selectedId), [targets, selectedId]);

  useEffect(() => { const timer = window.setTimeout(() => setSplash(false), 1800); return () => window.clearTimeout(timer); }, []);
  useEffect(() => { localStorage.setItem("mysaving-targets", JSON.stringify(targets)); }, [targets]);

  const go = (next: Screen) => { setScreen(next); setEditingTarget(false); setEditingTransaction(undefined); window.scrollTo(0, 0); };
  const openTarget = (id: string) => { setSelectedId(id); go("detail"); };
  const saveTarget = (target: SavingTarget) => {
    setTargets(items => items.some(item => item.id === target.id) ? items.map(item => item.id === target.id ? target : item) : [target, ...items]);
    setSelectedId(target.id); setEditingTarget(false); go("detail");
  };
  const deleteTarget = () => {
    if (!selected || !window.confirm(`Hapus target "${selected.name}" beserta seluruh riwayatnya?`)) return;
    setTargets(items => items.filter(item => item.id !== selected.id)); go("targets");
  };
  const saveTransaction = (transaction: Transaction) => {
    if (!selected) return;
    setTargets(items => items.map(item => item.id !== selected.id ? item : {
      ...item, transactions: item.transactions.some(tx => tx.id === transaction.id) ? item.transactions.map(tx => tx.id === transaction.id ? transaction : tx) : [transaction, ...item.transactions],
    }));
    setEditingTransaction(undefined); go("detail");
  };
  const deleteTransaction = (id: string) => {
    if (!selected || !window.confirm("Hapus transaksi tabungan ini?")) return;
    setTargets(items => items.map(item => item.id === selected.id ? { ...item, transactions: item.transactions.filter(tx => tx.id !== id) } : item));
  };

  if (splash) return <div className="flex min-h-dvh flex-col items-center justify-center overflow-hidden bg-[#203f36] text-white">
    <div className="relative"><div className="absolute -inset-9 animate-pulse rounded-full bg-[#d8f29e]/10" /><div className="relative grid size-24 place-items-center rounded-[30px] bg-[#d8f29e] text-[#203f36] shadow-2xl"><Icon name="wallet" size={45} strokeWidth={1.6} /></div></div>
    <div className="mt-7 text-3xl font-extrabold tracking-tight">MySaving<span className="text-[#e7a84b]">.</span></div>
    <p className="mt-2 text-sm text-white/55">Sedikit demi sedikit, jadi nyata.</p>
    <div className="absolute bottom-14 flex gap-1.5"><span className="size-1.5 animate-bounce rounded-full bg-[#d8f29e]" /><span className="size-1.5 animate-bounce rounded-full bg-[#d8f29e] [animation-delay:150ms]" /><span className="size-1.5 animate-bounce rounded-full bg-[#d8f29e] [animation-delay:300ms]" /></div>
  </div>;

  return <div className="mx-auto min-h-dvh max-w-[460px] bg-[#f7f8f5] shadow-[0_0_60px_rgba(24,43,35,.08)]">
    {screen === "home" && <Home targets={targets} go={go} openTarget={openTarget} />}
    {screen === "targets" && <Targets targets={targets} go={go} openTarget={openTarget} />}
    {screen === "profile" && <Profile targets={targets} reset={() => { if (window.confirm("Kembalikan data contoh awal?")) setTargets(demoTargets); }} />}
    {screen === "target-form" && <TargetForm current={editingTarget ? selected : undefined} onBack={() => go(editingTarget ? "detail" : "home")} onSave={saveTarget} onDelete={editingTarget ? deleteTarget : undefined} />}
    {screen === "detail" && selected && <Detail target={selected} go={go} edit={() => { setEditingTarget(true); setScreen("target-form"); }} remove={deleteTarget} />}
    {screen === "saving-form" && selected && <SavingForm target={selected} transaction={editingTransaction} onBack={() => go(editingTransaction ? "history" : "detail")} onSave={saveTransaction} />}
    {screen === "history" && selected && <History target={selected} onBack={() => go("detail")} onEdit={tx => { setEditingTransaction(tx); setScreen("saving-form"); }} onDelete={deleteTransaction} />}
    {["home", "targets", "profile", "detail"].includes(screen) && <BottomNav screen={screen} go={go} />}
  </div>;
}
