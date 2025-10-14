# README

残っているTODO：
- CSVをアップしたら、確認的な画面を導入したらより使い安い
- Building#room_numberのコラムはIntegerじゃなくてStringにした方がいいかもしれない
- CSVモデルにStatus的なコラムを追加して、Importができたかどうか歴史的なものとして使いそう
- もしメモリーが問題だったら、ImportしたらモデルをDestroyするように
- Production/Stagingの場合、RedisかSolidQueueの導入が必要。そしてRetryにしたい？
- 一戸建ての場合, room_numberあったら無視していい？それか問題あるから無視？営業再度の確認が必要
- Importする時、エラーがでたらどっかに報告するように（Bugsnagとか）

app/controllers/buildings_controller.rb
10:    # TODO Create a confirmation screen with preview of first ~10 records before creation, using @building_csv_file

db/schema.rb
52:    t.integer "room_number" # TODO Maybe this should be string? Never will do math to it

app/jobs/building_csv_import_job.rb
7:    # TODO Update building_csv_file to track status of update, if it's been run, etc
8:    # TODO Destroy model/file if memory is an issue
9:    # TODO For Production/Staging, need to use Redis or solid_queue, etc
20:            # TODO What do if ROOM_NUMBER is present even though it's a house? Ignoring for now but need to check
26:          # TODO Collect errors and submit to Error reporting OR stop using Job and expose all errors to user after redirect

spec/system/building_functionality_spec.rb
25:    # TODO check for 100+ records being paginated

Hello World!
