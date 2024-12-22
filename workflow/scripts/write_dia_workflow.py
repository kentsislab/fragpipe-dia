# inputs
input_workflow = snakemake.input["workflow"]
database = snakemake.input["database"]

# outputs
output_workflow = snakemake.output["workflow"]

# Read the file content
with open(input_workflow, 'r') as file:
    lines = file.readlines()

# Modify the specific line
for i, line in enumerate(lines):
    if line.startswith('database.db-path='):
        lines[i] = 'database.db-path=%s\n' % database
        break # stop loop after we've fixed

# Write the modified content back to the file
with open(output_workflow, 'w+') as file:
    file.writelines(lines)