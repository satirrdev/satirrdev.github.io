import { marked } from 'marked';
import type { Tokens } from 'marked';

marked.use({
  renderer: {
    table(this: any, token: Tokens.Table) {
      const renderer = this;
      let header = '';
      for (const cell of token.header) {
        header += renderer.tablecell(cell);
      }

      let body = '';
      for (const row of token.rows) {
        let cells = '';
        for (const cell of row) {
          cells += renderer.tablecell(cell);
        }
        body += `<tr>\n${cells}</tr>\n`;
      }

      return (
        `<div class="table-scroll">\n<table>\n<thead>\n<tr>\n${header}</tr>\n</thead>\n` +
        (body ? `<tbody>\n${body}</tbody>\n` : '') +
        `</table>\n</div>\n`
      );
    },
  },
});

export function parseMarkdown(content: string): string {
  const html = marked.parse(content, { async: false });
  return typeof html === 'string' ? html : '';
}
