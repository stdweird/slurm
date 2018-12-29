/*****************************************************************************\
 *  plugrack.h - an intelligent container for plugins
 *****************************************************************************
 *  Copyright (C) 2002 The Regents of the University of California.
 *  Produced at Lawrence Livermore National Laboratory (cf, DISCLAIMER).
 *  Written by Jay Windley <jwindley@lnxi.com>.
 *  CODE-OCEC-09-009. All rights reserved.
 *
 *  This file is part of Slurm, a resource management program.
 *  For details, see <https://slurm.schedmd.com/>.
 *  Please also read the included file: DISCLAIMER.
 *
 *  Slurm is free software; you can redistribute it and/or modify it under
 *  the terms of the GNU General Public License as published by the Free
 *  Software Foundation; either version 2 of the License, or (at your option)
 *  any later version.
 *
 *  In addition, as a special exception, the copyright holders give permission
 *  to link the code of portions of this program with the OpenSSL library under
 *  certain conditions as described in each individual source file, and
 *  distribute linked combinations including the two. You must obey the GNU
 *  General Public License in all respects for all of the code used other than
 *  OpenSSL. If you modify file(s) with this exception, you may extend this
 *  exception to your version of the file(s), but you are not obligated to do
 *  so. If you do not wish to do so, delete this exception statement from your
 *  version.  If you delete this exception statement from all source files in
 *  the program, then also delete it here.
 *
 *  Slurm is distributed in the hope that it will be useful, but WITHOUT ANY
 *  WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS
 *  FOR A PARTICULAR PURPOSE.  See the GNU General Public License for more
 *  details.
 *
 *  You should have received a copy of the GNU General Public License along
 *  with Slurm; if not, write to the Free Software Foundation, Inc.,
 *  51 Franklin Street, Fifth Floor, Boston, MA 02110-1301  USA.
\*****************************************************************************/

#ifndef __PLUGRACK_H__
#define __PLUGRACK_H__

#include <sys/types.h>

#include "src/common/plugin.h"
#include "src/common/list.h"

/* Opaque type for plugin rack. */
typedef struct _plugrack * plugrack_t;

/*
 * Returns a new plugin rack object on success and NULL on failure.
 */
plugrack_t plugrack_create(void);

/*
 * Destroy a plugin rack.  All the associated plugins are unloaded and
 * all associated memory is deallocated.
 *
 * Returns a Slurm errno.
 */
int plugrack_destroy(plugrack_t rack);

/*
 * Set the major type of the plugins for this rack.  This affects
 * subsequent calls to add plugins from files.
 *
 * Pass NULL to disable typing in plugins handled by this rack.
 * This is the default.
 *
 * Returns a Slurm errno.
 */
int plugrack_set_major_type(plugrack_t rack, const char *type);

/*
 * Add plugins to a rack by scanning the given directory.  If a
 * type has been set for this rack, only those plugins whose major type
 * matches the rack's type will be loaded.
 *
 * Returns a Slurm errno.
 */
int plugrack_read_dir(plugrack_t rack, const char *dir);

/*
 * Remove from memory all plugins that are not currently in use by the
 * program.
 *
 * Returns a Slurm errno.
 */
int plugrack_purge_idle(plugrack_t rack);

/*
 * Load into memory all plugins which are currently unloaded.
 *
 * Returns a Slurm errno.
 */
int plugrack_load_all(plugrack_t rack);

/*
 * Find a plugin in the rack which matches the given minor type,
 * load it if necessary, and return a handle to it.
 *
 * Returns PLUGIN_INVALID_HANDLE if a suitable plugin cannot be
 * found or loaded.
 */
plugin_handle_t plugrack_use_by_type(plugrack_t rack, const char *type);

/*
 * Indicate that a plugin is no longer needed.  Whether the plugin
 * is actually unloaded depends on the rack's disposal policy.
 *
 * Returns a Slurm errno.
 */
int plugrack_finished_with_plugin(plugrack_t rack, plugin_handle_t plug);

/*
 * print all plugins in rack
 *
 * Returns a Slurm errno.
 */
int plugrack_print_all_plugin(plugrack_t rack);

#endif /*__PLUGRACK_H__*/
