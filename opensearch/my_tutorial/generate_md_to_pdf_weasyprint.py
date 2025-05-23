import os
import markdown, weasyprint
from weasyprint import HTML

def convert_markdown_to_pdf(source_dir, target_dir):
    # Ensure the target directory exists
    os.makedirs(target_dir, exist_ok=True)

    for root, dirs, files in os.walk(source_dir):
        for file in files:
            if file.endswith('.md'):
                source_file_path = os.path.join(root, file)
                relative_path = os.path.relpath(root, source_dir)
                target_file_dir = os.path.join(target_dir, relative_path)
                target_file_path = os.path.join(target_file_dir, file.replace('.md', '.pdf'))

                # Ensure the target subdirectory exists
                os.makedirs(target_file_dir, exist_ok=True)

                # Read the markdown file
                with open(source_file_path, 'r', encoding='utf-8') as md_file:
                    md_content = md_file.read()

                # Convert markdown to HTML
                html_content = markdown.markdown(md_content,extensions=['extra'])

                # Convert HTML to PDF using WeasyPrint
                HTML(string=html_content, base_url=root).write_pdf(target_file_path)

                print(f"Generated PDF: {target_file_path}")

# Example usage
source_directory = 'docs'
target_directory = 'docs_pdf_weasyprint'
convert_markdown_to_pdf(source_directory, target_directory)