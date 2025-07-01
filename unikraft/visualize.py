import subprocess
import pandas as pd
import seaborn as sns
import matplotlib.pyplot as plt

# Directory to find code count in
tiny = "/home/edward/Documents/Thesis/arch/unikraft/tiny"
x86  = "/home/edward/Documents/Thesis/arch/unikraft/x86"
arm  = "/home/edward/Documents/Thesis/arch/unikraft/arm"

# Run 'cd' into the directory and then run 'scc'
tiny = int(subprocess.run(
    f"cd {tiny} && scc 2>/dev/null | awk '/^Total/ {{print $(NF-1)}}'",
    shell=True, stdout=subprocess.PIPE, text=True
).stdout.strip())

x86 = int(subprocess.run(
    f"cd {x86} && scc 2>/dev/null | awk '/^Total/ {{print $(NF-1)}}'",
    shell=True, stdout=subprocess.PIPE, text=True
).stdout.strip())

arm = int(subprocess.run(
    f"cd {arm} && scc 2>/dev/null | awk '/^Total/ {{print $(NF-1)}}'",
    shell=True, stdout=subprocess.PIPE, text=True
).stdout.strip())

# Create data for the bar chart
data = {
    "Config": ["Tiny", "x86", "ARM"],
    "Count": [tiny, x86, arm]
}

# Plot
df = pd.DataFrame(data)
sns.set(style="whitegrid")
ax = sns.barplot(x="Config", y="Count", data=df)

# Add value labels on top
for i, row in df.iterrows():
    ax.text(i, row["Count"] + max(df["Count"]) * 0.01, f"{row['Count']:,}", 
            ha='center', va='bottom', fontsize=10)

# Disable scientific notation
ax.get_yaxis().get_major_formatter().set_useOffset(False)
plt.ticklabel_format(style='plain', axis='y')

plt.title("LoC in deduplicated Unikraft kernel files")
plt.tight_layout()
plt.show()
