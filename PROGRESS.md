# KidsLearn AI — Progress (7th semester, ≈50% scope)

Status: **Not started** · **In progress** · **Done** (Done = works on the phone + analyze/tests clean + notes written + quiz passed, SRS 12.6.2).
Last update: 9 Nov 2026 (Week 4 task 1: PhoneticScorer). Emulator test evidence: notes/images/device_test_2026-10-28/, m2_create_story_2026-11-02/, m3_illustration_2026-11-02/, m2_story_preview_2026-11-03/, m2_story_library_2026-11-04/, m6_path_map_2026-11-05/, m6_story_viewer_2026-11-05/ and m6_story_complete_2026-11-06/.

## Week 1 foundation
| Item | Owner | Status | Notes |
|---|---|---|---|
| Step 0 environment (Flutter, Java, Android SDK) | Both | Done | Tested on the emulator; the physical phone (vivo Y21) is still to connect |
| Step 0 free-tier check (Groq, Cloudflare, Firebase) | Hanan | Done | Decisions 012, 013, 014 |
| Project skeleton, folders, fonts, theme tokens (SRS 10.11) | Wahab | In progress | Splash works on the emulator; night mode checked on emulator 28 Oct; quiz not answered yet; first commit 3189b3c pushed to private repo hanova-dev/kidslearn_ai, tag v0.1-m1-week1 (28 Oct) |

## M1 — Account, RBAC and onboarding (Wahab)
| FR | Requirement (short) | Status | Notes |
|---|---|---|---|
| FR-AUTH-01 | Email/password sign-up and login | In progress | Widget tests pass. **Emulator 28 Oct:** sign-up (Firebase session file created), log out, log in OK; wrong-password message seen by team. Waiting for quiz (decision 014) |
| FR-AUTH-02 | Child profile: name, buddy, age group, language | In progress | Widget tests pass. **Emulator 28 Oct:** empty-form messages shown; child saved (1 SQLite row: mango, reader_5_7, en). Bug found (old messages stayed after fixing a field) → fixed + test, re-checked on emulator. Waiting for quiz |
| FR-AUTH-03 | Parent screens only for signed-in parents | In progress | go_router redirect to /login. **Emulator 28 Oct:** signed-out start and log out both land on login. Waiting for quiz |
| FR-AUTH-04 | Parental gate (router guard) | In progress | Router guard + maths gate (decisions 003, 016). **Emulator 28 Oct:** wrong answer → new sum; right answer → parent home. Waiting for quiz |
| FR-AUTH-05 | Profile picker (who's reading?) | In progress | **Emulator 28 Oct:** child card shown; tap → "Hi, Ali!"; Home returns. **5 Nov:** tapping Ali or Sara now opens their real path map with their own buddy. Waiting for quiz |
| FR-AUTH-06 | Session kept locally (offline) | In progress | **Emulator 28 Oct:** force-close while unlocked → reopens on Who's reading, locked, still signed in, child kept (decision 016). Waiting for quiz |
| FR-HCI-01 | AgeExperiencePolicy (Listener/Reader) | Not started | |
| FR-HCI-04 | Fixed back/home/help positions (ChildScaffold) | Not started | |
| FR-HCI-05 | No solid red; colour + icon + sound | Not started | Decision 008 |

## M2 — Story generation (Hanan)
| FR | Requirement (short) | Status | Notes |
|---|---|---|---|
| FR-STORY-01 | Free-text prompt + language input | In progress | Create story screen (p7): text or value chip, child chips, English only (decisions 005, 019). **Emulator 2 Nov:** real Groq story for Sara ("Sky Shares Her Colors", 6 scenes). Waiting for quiz |
| FR-STORY-02 | StoryGenerationService → GroqStoryGenerator (JSON) | In progress | Service + adapter built, 7 mocked tests, real call OK 28 Oct (decisions 013, 017); used by screens in task 3 |
| FR-STORY-03 | Cache DRAFT in SQLite before network | In progress | StoryCreationController saves DRAFT before the Groq call (test checks the order). **Emulator 2 Nov:** offline story row saved with prompt_value 'Kindness'. Waiting for quiz (decisions 018, 019) |
| FR-STORY-04 | DRAFT / GENERATING / READY / FAILED + retry | In progress | Story generating screen (p8) + Try again. **Emulator 2 Nov:** writing screen seen; offline → "No internet…" + row FAILED; online + Try again → same story READY, 6 scenes. READY now only after all pictures (decision 020). **Story library (design p9, decision 023), emulator 4 Nov:** badges Writing…/Drawing…/Needs check/Approved/Stopped; a force-stopped story turned from GENERATING to FAILED at the next start and showed "Stopped". Waiting for quiz |
| FR-STORY-05 | Reject too-short prompts | In progress | StoryInputCheck, 15–300 letters in AppConfig, 6 tests. **Emulator 2 Nov:** empty → "Tell us what the story should teach…"; "Sara hits" → "Please write a little more…"; nothing sent. Waiting for quiz |
| FR-STORY-06 | Regenerate from same prompt | In progress | "Make a new version" on the preview replaces text + pictures of the same story, keeps the prompt, clears approval (decision 022). Unit + widget tested. **Emulator 3 Nov:** "Sky's Gentle Bedtime" got 6 new sentences and 6 new FLUX files, same id, no extra story. **4 Nov:** a Stopped story from the library got a new version ("Mango Tries a New Bite", 6 FLUX). Waiting for quiz |
| FR-STORY-07 | Parent preview and approve | In progress | Story preview screen: scene list, Approve, Make a new version, Delete with confirm (decisions 011, 022). Unit + widget tested. **Emulator 3 Nov:** Approve → approved = 1 and "Approved. Sara can read it."; Delete → 0 rows, 0 files, "Story deleted." **4 Nov:** opened and approved from the Story library (badge Needs check → Approved, approved = 1); night mode checked. **5 Nov:** only approved stories reach the child: Ali's path had 1 circle, then 3 after approving 2 more (decision 024). Waiting for quiz |
| FR-STORY-08 | Real name → buddy name in prompts | In progress | StoryPromptBuilder.redactName, 8 tests + controller test (decision 017). **Emulator 2 Nov:** prompt "Sara does not want…" → story about Sky; "Sara" not found in title, character sheet or scenes. Waiting for quiz |

## M3 — Illustration (Hanan)
| FR | Requirement (short) | Status | Notes |
|---|---|---|---|
| FR-ILLUS-01 | IllustrationService → FluxIllustrator + character sheet | In progress | Style text + character sheet + scene, no seed (decisions 012, 020), 7 mocked tests. **Emulator 2 Nov:** "Mango Tries New Food", 6 FLUX pictures in ~16 s, same fox in each. Issue: FLUX wrote "Mango" on 3 of 6 pictures. Fix (decision 021): buddy name replaced by "the fox" in picture prompts + "wordless picture" style text. Direct API test: 0 of 6 with text; unit-tested. **Emulator 3 Nov:** "Mango Tries a New Taste", 6 FLUX pictures, none with text. Waiting for quiz |
| FR-ILLUS-02 | Image saved as file, path in SQLite | In progress | ImageFileStore + saveSceneImage, tested. **Emulator 2 Nov:** 6 JPG files (236–561 KB) in app_flutter/story_images, paths + 'FLUX' in scenes. Waiting for quiz |
| FR-ILLUS-03 | Show scenes progressively | In progress | Story generating: "Drawing scene N of 6" + thumbnails. **Emulator 2 Nov:** seen at scene 4 of 6 with 3 thumbnails. Waiting for quiz |
| FR-ILLUS-04 | Retry one failed scene | In progress | FluxIllustrator retries 2 times (1 s, 2 s), 401 not retried; tested with mocks. Parent "retry pictures later" comes with preview (task 2). Waiting for quiz |
| FR-ILLUS-05 | Choose 512 / 1024 resolution | Dropped | Not supported by the API (decision 012) |
| FR-ILLUS-06 | PlaceholderIllustrator fallback | In progress | PNG from SceneryPainter (decision 010), per-scene fallback (decision 020). **Emulator 2 Nov:** network cut while drawing → 6 PLACEHOLDER pngs, story still READY, note shown. **Retry later (3 Nov):** "Draw pictures again" on the preview turned 4 PLACEHOLDER scenes into FLUX and removed the old pngs (decision 022). Waiting for quiz |

## M4 — Speech-to-text (Hanan)
| FR | Requirement (short) | Status | Notes |
|---|---|---|---|
| FR-STT-01 | Mic only while the child triggers it | Not started | |
| FR-STT-02 | SpeechToTextService → GroqWhisperTranscriber | In progress | Spike works (0.7 s) |
| FR-STT-03 | Language from child profile | Not started | English only, decision 005 |
| FR-STT-04 | Delete audio after transcription | Not started | |
| FR-STT-05 | Retry when no speech detected | Not started | |
| FR-STT-06 | One sentence per request | Not started | Decision 004 |
| FR-STT-07 | DeviceSpeechRecognizer fallback | Not started | Needs the physical phone |

## M5 — PhoneticScorer (Hanan)
| FR | Requirement (short) | Status | Notes |
|---|---|---|---|
| FR-SCORE-01 | Double Metaphone codes | In progress | Unit-tested (42 algorithm tests pass). Own documented subset, decision 027; `double_metaphone_test.dart`. Phone check with Reader Mode; waiting for quiz |
| FR-SCORE-02 | Levenshtein distance | In progress | Unit-tested (42 algorithm tests pass). Tests written first; `levenshtein_test.dart`. Phone check with Reader Mode; waiting for quiz |
| FR-SCORE-03 | Normalised similarity | In progress | Unit-tested (42 algorithm tests pass). 1 - distance / longer code; `phonetic_scorer_test.dart`. Phone check with Reader Mode; waiting for quiz |
| FR-SCORE-04 | CORRECT / NEAR_MISS / TRY_AGAIN | In progress | Unit-tested (42 algorithm tests pass). `Verdict` enum with SQLite text. Phone check with Reader Mode; waiting for quiz |
| FR-SCORE-05 | Per-language thresholds | In progress | Unit-tested (42 algorithm tests pass). en 0.80/0.55, ur 0.72/0.47; tunable (decision 027). Phone check with Reader Mode; waiting for quiz |
| FR-SCORE-06 | Practice-word list | Not started | |
| FR-SCORE-07 | Colours within 300 ms | In progress | Scorer 0.75 ms per sentence on the laptop; colours come with Reader Mode; phone not measured |
| FR-SCORE-08 | Word alignment (SRS 8.1.6) | In progress | Unit-tested (42 algorithm tests pass). Skipped, extra, repeated and changed words; `word_aligner_test.dart`. Phone check with Reader Mode; waiting for quiz |

## M6 (partial) — Basic Reader Mode (Wahab)
| FR | Requirement (short) | Status | Notes |
|---|---|---|---|
| Path map (design p15; FR-MODE-01, D1, D6) | Child's story path | In progress | Approved stories as circles: finished / current / locked, linear unlocking from a new reading_sessions table (DB version 3, decision 024). Unit + widget tested. **Emulator 5 Nov:** DB 2 → 3 kept 9 stories; 1 then 3 circles after approving; hand-inserted test session → story 1 green, story 2 "Tap to play!"; locked tap → "Finish the glowing story first!"; night mode checked. Tap now opens the story viewer. Waiting for quiz |
| Story viewer (design p13; decisions 006, 025) | Page-by-page story for the child | In progress | Picture + Andika sentence, page dots, Previous/Next, "The end" → path; only approved READY stories (FR-STORY-07). Both age groups for now. Unit + widget tested. **Emulator 5 Nov:** Sara's FLUX story 6 pages, Previous hidden on page 1, "The end" → path; story without pictures shows scenery; night mode checked. Waiting for quiz |
| FR-TTS-01/02/03 | Read aloud with the phone's voice | In progress | flutter_tts 4.2.5, TextToSpeechService + DeviceTtsNarrator (decision 025). **Emulator 5 Nov:** Google TTS embedded en-US voice (offline) spoke the sentence; turning the page and "The end" stopped it (logcat "Interrupted: true"). "No voice" message widget-tested only. Clip caching and karaoke not built. Waiting for quiz |
| FR-MODE-01 | Mode by age group | Not started | Both groups use the viewer until Reader Mode (Week 4); then ListenerPolicy / ReaderPolicy (decisions 006, 025) |
| FR-MODE-04 | Tap-and-read before advancing | Not started | Whole sentence, decision 004 |
| FR-MODE-05 | Live colour feedback | Not started | |
| FR-MODE-06 | Stars on completion (simple) | In progress | Story complete (design p22, decision 026): "The end" saves a reading_sessions row and 1 star per page to star_balance; spoken "You did it, <name>!"; Next adventure / Read it again. Unit + widget tested. **Emulator 6 Nov:** Sara +6 (48 words, LISTENER); Ali story 2 → +6 and story 3 unlocked by itself; Read it again +6 → 12; stars kept after restart; night mode checked. Reader Mode will use the 3/2/1 rule (decision 009) in Week 4. Waiting for quiz |

## Cross-cutting
| ID | Requirement (short) | Status | Notes |
|---|---|---|---|
| NFR-SEC-03 | Keys never in source control | In progress | env/ in .gitignore; check before first commit |
| NFR-USE-03 | Plain-language errors with retry | In progress | Login errors mapped to plain sentences (AuthFailure) |
| NFR-REL-02 | 15 s timeout, 2 retries | In progress | Done for Groq story calls; FLUX and Whisper later |
| NFR-REL-05 | Fallback adapter for every AI service | Not started | |
| NFR-PERF-01 | Verdict ≤ 300 ms | In progress | `phonetic_scorer_speed_test.dart` + `tool/scorer_speed_check.dart` (0.75 ms on the laptop); phone not measured |
