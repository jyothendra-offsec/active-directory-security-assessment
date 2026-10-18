"""Original, reproducible project diagrams. Requires matplotlib."""
from pathlib import Path
import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt
from matplotlib.patches import FancyBboxPatch
OUT=Path(__file__).parent
BG='#091526'; CARD='#12263d'; WHITE='#eff6ff'; MUTED='#a4bad1'; CYAN='#47ddd0'; GOLD='#ffcc74'
def setup(title,sub):
 fig,ax=plt.subplots(figsize=(14,8));fig.patch.set_facecolor(BG);ax.set_facecolor(BG)
 ax.set(xlim=(0,14),ylim=(0,8));ax.axis('off')
 ax.text(.6,7.35,title,color=WHITE,size=25,weight='bold');ax.text(.6,6.88,sub,color=MUTED,size=12)
 return fig,ax
def box(ax,x,y,w,h,title,body,color=CYAN):
 ax.add_patch(FancyBboxPatch((x,y),w,h,boxstyle='round,pad=0.02,rounding_size=.12',facecolor=CARD,edgecolor=color,lw=1.4))
 ax.text(x+.2,y+h-.35,title,color=color,size=14,weight='bold',va='top')
 ax.text(x+.2,y+h-.87,body,color=WHITE,size=11,va='top',linespacing=1.6)
def arrow(ax,a,b,color=CYAN): ax.annotate('',xy=b,xytext=a,arrowprops={'arrowstyle':'->','color':color,'lw':1.8})
def save(fig,name):
 fig.savefig(OUT/(name+'.png'),dpi=160,facecolor=BG,bbox_inches='tight');fig.savefig(OUT/(name+'.svg'),facecolor=BG,bbox_inches='tight');plt.close(fig)
f,a=setup('ACTIVE DIRECTORY SECURITY ASSESSMENT','An isolated identity lab • Original design diagram • No execution results implied')
box(a,.6,3.5,3.8,2.45,'IDENTITY / AD-ID','DC01  ·  10.77.10.10\nAD DS + DNS + Kerberos\ncorp.lab.test')
box(a,9.6,3.5,3.8,2.45,'SERVERS / AD-SRV','SRV01  ·  10.77.20.20\nDomain member\nControlled resource access')
box(a,5.15,3.75,3.7,1.95,'FW01 / BOUNDARY','Three internal interfaces\nDefault-deny forwarding',GOLD)
box(a,3.45,.7,7.1,1.95,'CLIENTS / AD-CLIENT','WS01  ·  10.77.30.30     |     AUDIT01  ·  10.77.30.50\nSame subnet: endpoint controls still matter')
arrow(a,(5.15,4.65),(4.4,4.65));arrow(a,(7,2.65),(7,3.75))
a.plot([8.85,9.6],[4.65,4.65],color=GOLD,lw=1.8,ls='--')
a.text(11.45,3.12,'Admin traffic blocked by baseline',color=GOLD,size=10,ha='center')
a.text(.6,.17,'No WAN • No NAT • No bridge • Console administration • Coordinated checkpoints',color=MUTED,size=11)
save(f,'architecture')
f,a=setup('FROM HYPOTHESIS TO DEFENSIBLE FINDING','A repeatable method for validating access, detecting activity, and measuring remediation')
for args in [(.6,4.15,'01  FORM A HYPOTHESIS','Inventory identities and rights\nRecord scope and prerequisites'),(5,4.15,'02  VALIDATE ONE PATH','Controlled account + operation\nCompare expected and observed'),(9.4,4.15,'03  COLLECT EVIDENCE','Windows events + firewall data\nUTC time + SHA256 manifest'),(9.4,1,'04  REMEDIATE','Remove the causal weakness\nPreserve business functionality'),(5,1,'05  REPEAT THE TEST','Same source, target and identity\nFresh logon / known state'),(.6,1,'06  REPORT THE RESULT','Observed impact and limitations\nRedacted proof + residual risk')]:
 x,y,t,b=args;box(a,x,y,4,1.95,t,b)
for p,q in [((4.6,5.1),(5,5.1)),((9,5.1),(9.4,5.1)),((11.4,4.15),(11.4,2.95)),((9.4,1.95),(9,1.95)),((5,1.95),(4.6,1.95))]:arrow(a,p,q)
a.text(.6,.3,'A ticket is not a cracked password. Authentication is not authorization. A graph is not proof.',color=GOLD,size=12)
save(f,'evidence-workflow')
