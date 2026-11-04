# KidsLearn AI — Progress (7th semester, ≈50% scope)

Status: **Not started** · **In progress** · **Done** (Done = works on the phone + analyze/tests clean + notes written + quiz passed, SRS 12.6.2).
Last update: 2 Nov 2026 (M3 task 1: drawing scenes). Emulator test evidence: notes/images/device_test_2026-10-28/ notes/images/m2_create_story_2026-11-02/ and notes/images/m3_illustration_2026-11-02/.

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
| FR-AUTH-05 | Profile picker (who's reading?) | In progress | **Emulator 28 Oct:** child card shown; tap → "Hi, Ali!"; Home returns. Path map is a placeholder until Week 3. Waiting for quiz |
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
| FR-STORY-04 | DRAFT / GENERATING / READY / FAILED + retry | In progress | Story generating screen (p8) + Try again. **Emulator 2 Nov:** writing screen seen; offline → "No internet…" + row FAILED; online + Try again → same story READY, 6 scenes. READY now only after all pictures (decision 020). Waiting for quiz |
| FR-STORY-05 | Reject too-short prompts | In progress | StoryInputCheck, 15–300 letters in AppConfig, 6 tests. **Emulator 2 Nov:** empty → "Tell us what the story should teach…"; "Sara hits" → "Please write a little more…"; nothing sent. Waiting for quiz |
| FR-STORY-06 | Regenerate from same prompt | In progress | "Make a new version" on the preview replaces text + pictures of the same story, keeps the prompt, clears approval (decision 022). Unit + widget tested. **Emulator 3 Nov:** "Sky's Gentle Bedtime" got 6 new sentences and 6 new FLUX files, same id, no extra story. Waiting for quiz |
| FR-STORY-07 | Parent preview and approve | In progress | Story preview screen: scene list, Approve, Make a new version, Delete with confirm (decisions 011, 022). Unit + widget tested. **Emulator 3 Nov:** Approve → approved = 1 and "Approved. Sara can read it."; Delete → 0 rows, 0 files, "Story deleted." Night mode not checked yet. Waiting for quiz |
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
| FR-SCORE-01 | Double Metaphone codes | Not started | Package vs own subset: team must choose |
| FR-SCORE-02 | Levenshtein distance | Not started | Tests first |
| FR-SCORE-03 | Normalised similarity | Not started | |
| FR-SCORE-04 | CORRECT / NEAR_MISS / TRY_AGAIN | Not started | |
| FR-SCORE-05 | Per-language thresholds | Not started | |
| FR-SCORE-06 | Practice-word list | Not started | |
| FR-SCORE-07 | Colours within 300 ms | Not started | Benchmark on the phone |
| FR-SCORE-08 | Word alignment (SRS 8.1.6) | Not started | Tests first |

## M6 (partial) — Basic Reader Mode (Wahab)
| FR | Requirement (short) | Status | Notes |
|---|---|---|---|
| FR-MODE-01 | Mode by age group | Not started | Simple viewer for 2–4, decision 006 |
| FR-MODE-04 | Tap-and-read before advancing | Not started | Whole sentence, decision 004 |
| FR-MODE-05 | Live colour feedback | Not started | |
| FR-MODE-06 | Stars on completion (simple) | Not started | Decision 009 |

## Cross-cutting
| ID | Requirement (short) | Status | Notes |
|---|---|---|---|
| NFR-SEC-03 | Keys never in source control | In progress | env/ in .gitignore; check before first commit |
| NFR-USE-03 | Plain-language errors with retry | In progress | Login errors mapped to plain sentences (AuthFailure) |
| NFR-REL-02 | 15 s timeout, 2 retries | In progress | Done for Groq story calls; FLUX and Whisper later |
| NFR-REL-05 | Fallback adapter for every AI service | Not started | |
| NFR-PERF-01 | Verdict ≤ 300 ms | Not started | |
