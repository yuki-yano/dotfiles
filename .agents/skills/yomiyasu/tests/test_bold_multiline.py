#!/usr/bin/env python3
"""Issue #2: 複数行太字およびブロック境界における太字検査の回帰テスト"""
import unittest
import sys
from pathlib import Path

# scripts をインポートパスに追加
SCRIPTS_DIR = Path(__file__).resolve().parent.parent / "scripts"
sys.path.insert(0, str(SCRIPTS_DIR))

import yomiyasu_lint
import yomiyasu_diff


class TestBoldMultiline(unittest.TestCase):

    def test_issue2_reproduction(self):
        """Issue #2 本文の再現例:
        2行にまたがる正常な太字の後に別の太字がある場合、誤検出してはならない。
        """
        text = "**太字は1行目から始まり、\n2行目で閉じる。** 続きの文には**別の太字**もある。"
        problems = yomiyasu_lint.bold_problems(text)
        self.assertEqual(problems, [], f"Issue #2 should not produce findings, but got: {problems}")

        diff_problems = yomiyasu_diff.bold_problems(text)
        self.assertEqual(diff_problems, [], f"yomiyasu_diff should also not produce findings, but got: {diff_problems}")

    def test_issue2_comment_even_delimiters(self):
        """Issue #2 投稿者追加コメントの再現例:
        1行内の ** の個数が偶数でも、2つの複数行太字が行2で交差するケース。
        誤検出0件かつ両方の太字が維持されること。
        """
        text = "**太字は1行目から始まり、\n2行目で閉じる。** 続きの文では**次の太字が始まり、\n3行目で閉じる。**"
        problems = yomiyasu_lint.bold_problems(text)
        self.assertEqual(problems, [], f"Issue #2 comment example should not produce findings, got: {problems}")

        diff_problems = yomiyasu_diff.bold_problems(text)
        self.assertEqual(diff_problems, [], f"yomiyasu_diff should also not produce findings, got: {diff_problems}")

    def test_normal_multiline_bold_3lines(self):
        """正常な3行にまたがる太字: 誤検出してはならない"""
        text = "**1行目から始まり、\n2行目を経由して、\n3行目で閉じる。**"
        problems = yomiyasu_lint.bold_problems(text)
        self.assertEqual(problems, [])

    def test_normal_multiline_with_preceding_and_subsequent_bold(self):
        """先行太字、複数行太字、後続太字が混在する段落"""
        text = "**先行** 通常テキスト **2行に\nまたがる太字** 通常テキスト **後続**"
        problems = yomiyasu_lint.bold_problems(text)
        self.assertEqual(problems, [])

    def test_broken_multiline_bold(self):
        """実際に壊れている複数行太字:
        文字と括弧に挟まれてGFMで太字にならない複数行太字は正しく検出され、
        改行を維持した適切な修正案が出されること。
        """
        text = "次に**「太字は1行目から始まり、\n2行目で閉じる。」**を決めます。"
        problems = yomiyasu_lint.bold_problems(text)
        self.assertEqual(len(problems), 1)
        p = problems[0]
        self.assertEqual(p["line"], 1)
        self.assertEqual(p["how"], "かっこの内側だけを太字にする")
        self.assertIn("「**太字は1行目から始まり、\n2行目で閉じる。**」", p["suggest"])

    def test_block_boundary_blank_line(self):
        """空行によるブロック境界:
        段落1の未閉太字と段落2の太字閉じが空行をまたいで誤ってペアになってはならない。
        """
        text = "**段落1で開いたまま\n\n段落2で閉じる。**"
        problems = yomiyasu_lint.bold_problems(text)
        # 空行をまたいでペアにしてはならない
        self.assertEqual(problems, [])

    def test_block_boundary_heading(self):
        """見出しによるブロック境界:
        見出しと後続の段落がまたがってペアになってはならない。
        """
        text = "# **見出しの太字\n本文で閉じる。**"
        problems = yomiyasu_lint.bold_problems(text)
        self.assertEqual(problems, [])

    def test_block_boundary_list(self):
        """リスト項目によるブロック境界:
        別のリスト項目をまたいで太字がペアになってはならない。
        """
        text = "- **リスト1で開き\n- リスト2で閉じる**"
        problems = yomiyasu_lint.bold_problems(text)
        self.assertEqual(problems, [])

    def test_multiline_inline_code(self):
        """複数行にまたがるインラインコード内の ** はスキップされること"""
        text = "`code line 1\n**not bold in code**\ncode line 2`"
        problems = yomiyasu_lint.bold_problems(text)
        self.assertEqual(problems, [])

    def test_fenced_code_blocks(self):
        """バッククォートおよびチルダのフェンスコードブロック内はスキップされること"""
        text = "```\n**not bold**\n```\n~~~\n**also not bold**\n~~~"
        problems = yomiyasu_lint.bold_problems(text)
        self.assertEqual(problems, [])

    def test_escaped_asterisks(self):
        """エスケープされた \\*\\* は太字として認識されないこと"""
        text = r"\*\*これは太字ではない\*\*"
        problems = yomiyasu_lint.bold_problems(text)
        self.assertEqual(problems, [])

    def test_crlf_newlines(self):
        """CRLF改行の文書でも正常に動作すること"""
        text = "**太字は1行目から始まり、\r\n2行目で閉じる。** 続きの文には**別の太字**もある。"
        problems = yomiyasu_lint.bold_problems(text)
        self.assertEqual(problems, [])

    def test_traditional_single_line_broken_bold(self):
        """従来の単一行の壊れた太字が正しく検出されること"""
        # 1. かっこの内側
        t1 = "次に**「文書の立場」**を決めます。"
        p1 = yomiyasu_lint.bold_problems(t1)
        self.assertEqual(len(p1), 1)
        self.assertEqual(p1[0]["how"], "かっこの内側だけを太字にする")
        self.assertIn("「**文書の立場**」", p1[0]["suggest"])

        # 2. 句点を外に出す
        t2 = "これは**必須です。**詳しくは下に書きます。"
        p2 = yomiyasu_lint.bold_problems(t2)
        self.assertEqual(len(p2), 1)
        self.assertEqual(p2[0]["how"], "句読点を太字の外に出す")
        self.assertIn("**必須です**。", p2[0]["suggest"])

        # 3. 半角スペース
        t3 = "立場は**「勧め」か「決まり」**で決めます。"
        p3 = yomiyasu_lint.bold_problems(t3)
        self.assertEqual(len(p3), 1)
        self.assertEqual(p3[0]["how"], "文字に接する側に半角スペースを入れる")
        self.assertIn(" **「勧め」か「決まり」** ", p3[0]["suggest"])

    def test_line_number_reporting(self):
        """複数行太字の開始行が line として正しく報告されること"""
        text = "1行目\n2行目\n3行目で**「太字が始まり、\n4行目で閉じる。」**のを決めます。"
        problems = yomiyasu_lint.bold_problems(text)
        self.assertEqual(len(problems), 1)
        self.assertEqual(problems[0]["line"], 3)

    def test_inner_whitespace_regression(self):
        """内側空白の検出（8d5abeeからの退行防止）:
        ** 重要 **, 次は**重要 **です, 次は** 重要**です
        がそれぞれ1件検出され、「太字の内側の空白を取る」案が出ること。
        yomiyasu_lint と yomiyasu_diff の両方で検証する。
        """
        cases = [
            ("** 重要 **", "**重要**"),
            ("次は**重要 **です", "次は**重要**です"),
            ("次は** 重要**です", "次は**重要**です"),
        ]
        for src, expected_suggest in cases:
            # yomiyasu_lint
            probs_lint = yomiyasu_lint.bold_problems(src)
            self.assertEqual(len(probs_lint), 1, f"yomiyasu_lint should detect 1 problem in {repr(src)}, got {probs_lint}")
            self.assertEqual(probs_lint[0]["how"], "太字の内側の空白を取る")
            self.assertEqual(probs_lint[0]["suggest"], expected_suggest)

            # yomiyasu_diff
            probs_diff = yomiyasu_diff.bold_problems(src)
            self.assertEqual(len(probs_diff), 1, f"yomiyasu_diff should detect 1 problem in {repr(src)}, got {probs_diff}")
            self.assertEqual(probs_diff[0]["how"], "太字の内側の空白を取る")
            self.assertEqual(probs_diff[0]["suggest"], expected_suggest)

    def test_inner_whitespace_multiline(self):
        """複数行にまたがる内側空白の太字も正しく検出されること"""
        text = "** 重要\n重要 **"
        probs = yomiyasu_lint.bold_problems(text)
        self.assertEqual(len(probs), 1)
        self.assertEqual(probs[0]["how"], "太字の内側の空白を取る")
        self.assertIn("**重要\n重要**", probs[0]["suggest"])

    def test_bold_head_message(self):
        """CLI出力見出し（bold_head）に『案のとおりに直す』が含まれず、
        表示可否と案の範囲の確認を促す安全な指示になっていること。
        """
        head = yomiyasu_diff.bold_head()
        self.assertNotIn("案のとおりに直す", head)
        self.assertIn("表示可否と案の範囲を確認して直す", head)

    def test_regression_matrix_all_cases(self):
        """リポジトリ内 fixture (tests/fixtures/bold_regressions.json) の全50ケースの検証:
        外部ディレクトリやオンラインAPIに依存せず、常に全件検証する。
        """
        import json
        fixture_path = Path(__file__).resolve().parent / "fixtures" / "bold_regressions.json"
        self.assertTrue(fixture_path.exists(), f"Required test fixture not found: {fixture_path}")

        with open(fixture_path, encoding="utf-8") as f:
            cases = json.load(f)

        self.assertEqual(len(cases), 50, f"Expected 50 cases in fixture, found {len(cases)}")

        for x in cases:
            case_id = x["id"]
            text = x["text"]
            exp = x.get("expected_bold_problems")
            expected_lines = x.get("expected_line_numbers", [])

            lint_probs = yomiyasu_lint.bold_problems(text)
            diff_probs = yomiyasu_diff.bold_problems(text)

            # lint と diff の結果が完全に一致すること
            self.assertEqual(
                len(lint_probs), len(diff_probs),
                f"[{case_id}] lint vs diff count mismatch: lint={len(lint_probs)}, diff={len(diff_probs)}"
            )
            self.assertEqual(
                lint_probs, diff_probs,
                f"[{case_id}] lint vs diff findings mismatch"
            )

            if exp is not None:
                self.assertEqual(
                    len(lint_probs), exp,
                    f"[{case_id}] expected {exp} problems, got {len(lint_probs)}: {lint_probs}"
                )
                if exp > 0 and expected_lines:
                    self.assertEqual(
                        [f["line"] for f in lint_probs], expected_lines,
                        f"[{case_id}] line numbers mismatch: expected {expected_lines}, got {[f['line'] for f in lint_probs]}"
                    )
            else:
                # 境界安全ケース: ブロックをまたぐ破壊的修正案（suggest）を出さないこと
                self.assertFalse(
                    any(f.get("suggest") for f in lint_probs),
                    f"[{case_id}] boundary safety case produced unexpected auto-repair: {lint_probs}"
                )


if __name__ == "__main__":
    unittest.main()

